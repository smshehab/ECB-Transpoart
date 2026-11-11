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

test('a normal user can create and read their own profile but cannot change role', async () => {
  const db = env.authenticatedContext('user-1', { email: 'user@example.test', role: 'user' }).firestore();
  await assertSucceeds(setDoc(doc(db, 'users/user-1'), {
    displayName: 'Normal User',
    email: 'user@example.test',
    role: 'user',
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  }));
  await assertSucceeds(getDoc(doc(db, 'users/user-1')));
  await assertFails(updateDoc(doc(db, 'users/user-1'), { role: 'admin' }));
});

test('a guest can read public transport data but cannot write it', async () => {
  await env.withSecurityRulesDisabled(async context => {
    await setDoc(doc(context.firestore(), 'buses/public-bus'), { name: 'Public Bus' });
  });
  const guestDb = env.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(guestDb, 'buses/public-bus')));
  await assertFails(setDoc(doc(guestDb, 'buses/guest-write'), { name: 'Not allowed' }));
});

test('only ADMIN can create or modify fleet records', async () => {
  const userDb = env.authenticatedContext('user-2', { role: 'user' }).firestore();
  const adminDb = env.authenticatedContext('admin-1', { role: 'admin' }).firestore();
  await assertFails(setDoc(doc(userDb, 'buses/user-bus'), { name: 'Unauthorized' }));
  await assertSucceeds(setDoc(doc(adminDb, 'buses/admin-bus'), { name: 'Authorized' }));
});

test('only ADMIN can change trip records', async () => {
  const userDb = env.authenticatedContext('user-3', { role: 'user' }).firestore();
  const adminDb = env.authenticatedContext('admin-2', { role: 'admin' }).firestore();
  await assertFails(setDoc(doc(userDb, 'trips/user-trip'), { busId: 'bus-1', status: 'scheduled' }));
  await assertSucceeds(setDoc(doc(adminDb, 'trips/admin-trip'), { busId: 'bus-1', status: 'scheduled' }));
});

test('legacy privileged role names do not grant ADMIN permissions', async () => {
  const legacyAdmin = env.authenticatedContext('legacy-admin', { role: 'transport_admin' }).firestore();
  await assertFails(setDoc(doc(legacyAdmin, 'buses/legacy-write'), { name: 'Not allowed' }));
});
