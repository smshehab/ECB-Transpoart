import { readFile } from 'node:fs/promises';
import { before, after, test } from 'node:test';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, getDoc, updateDoc, serverTimestamp } from 'firebase/firestore';

let env;
before(async () => {
  const rules = await readFile(new URL('../firestore.rules', import.meta.url), 'utf8');
  env = await initializeTestEnvironment({ projectId: 'ecb-transport-rules-test', firestore: { rules } });
});
after(async () => { await env.cleanup(); });

test('passenger can create and read own profile but cannot grant admin role', async () => {
  const db = env.authenticatedContext('passenger-1', { email: 'passenger@example.test' }).firestore();
  await assertSucceeds(setDoc(doc(db, 'users/passenger-1'), {
    displayName: 'Passenger', email: 'passenger@example.test', createdAt: serverTimestamp(), updatedAt: serverTimestamp(),
  }));
  await assertSucceeds(getDoc(doc(db, 'users/passenger-1')));
  await assertFails(updateDoc(doc(db, 'users/passenger-1'), { role: 'super_admin' }));
});

test('unauthenticated users cannot read fleet records', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'buses/bus-1'), { name: 'Test Bus' });
  });
  await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'buses/bus-1')));
});

test('only administrators can create fleet records', async () => {
  const passengerDb = env.authenticatedContext('passenger-2', { email: 'p2@example.test' }).firestore();
  const adminDb = env.authenticatedContext('admin-1', { role: 'transport_admin' }).firestore();
  await assertFails(setDoc(doc(passengerDb, 'buses/bus-2'), { name: 'Unauthorized' }));
  await assertSucceeds(setDoc(doc(adminDb, 'buses/bus-3'), { name: 'Authorized' }));
});


test('only the assigned driver claim can perform permitted trip state changes', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'trips/trip-1'), {
      driverId: 'driver-1', busId: 'bus-1', status: 'scheduled',
    });
  });
  const passengerDb = env.authenticatedContext('driver-1', { role: 'passenger' }).firestore();
  const driverDb = env.authenticatedContext('driver-1', { role: 'driver' }).firestore();
  await assertFails(updateDoc(doc(passengerDb, 'trips/trip-1'), { status: 'active' }));
  await assertSucceeds(updateDoc(doc(driverDb, 'trips/trip-1'), { status: 'active', startedAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(driverDb, 'trips/trip-1'), { busId: 'other-bus' }));
  await assertSucceeds(updateDoc(doc(driverDb, 'trips/trip-1'), { status: 'completed', completedAt: serverTimestamp() }));
});

test('trip records are visible only to the assigned driver and administrators', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'trips/private-trip'), {
      driverId: 'assigned-driver', busId: 'bus-private', status: 'active',
    });
  });
  const passengerDb = env.authenticatedContext('passenger-9', { role: 'passenger' }).firestore();
  const otherDriverDb = env.authenticatedContext('other-driver', { role: 'driver' }).firestore();
  const assignedDriverDb = env.authenticatedContext('assigned-driver', { role: 'driver' }).firestore();
  const adminDb = env.authenticatedContext('admin-9', { role: 'transport_admin' }).firestore();
  await assertFails(getDoc(doc(passengerDb, 'trips/private-trip')));
  await assertFails(getDoc(doc(otherDriverDb, 'trips/private-trip')));
  await assertSucceeds(getDoc(doc(assignedDriverDb, 'trips/private-trip')));
  await assertSucceeds(getDoc(doc(adminDb, 'trips/private-trip')));
});
