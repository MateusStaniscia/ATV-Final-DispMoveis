const { test } = require('node:test');
const assert = require('node:assert/strict');
const { initializeApp, deleteApp } = require('firebase/app');
const { getAuth, connectAuthEmulator, createUserWithEmailAndPassword,
  signInWithEmailAndPassword, signOut, sendPasswordResetEmail } = require('firebase/auth');
const { getFirestore, connectFirestoreEmulator, doc, setDoc, getDoc, terminate } = require('firebase/firestore');
const scores=Object.fromEntries(["resenha","presenca_vip","aura","modo_parceiro","carisma_natural","humor_de_milhoes","energia_de_grupo","criatividade_caotica","modo_atleta","talento_de_palco","drip_escolar","coracao_de_dorama","queridinho_dos_professores","cerebro_turbo","caos_controlado"].map(k=>[k,3]));
test('Authentication real do emulador: cadastro, senha errada, login, reset e logout', async () => {
  const app=initializeApp({apiKey:'demo-api-key',projectId:'demo-piramid-game'},'auth-'+Date.now());
  const auth=getAuth(app);
  connectAuthEmulator(auth,'http://127.0.0.1:9099',{disableWarnings:true});
  const db=getFirestore(app);
  connectFirestoreEmulator(db,'127.0.0.1',8080);
  const email='teste-'+Date.now()+'@example.com', password='SenhaTeste123!';
  try {
    const credential=await createUserWithEmailAndPassword(auth,email,password);
    const uid=credential.user.uid;
    const ref=doc(db,'users',uid,'students','integracao');
    await setDoc(ref,{id:'integracao',name:'Integração',course:'TADS',year:2026,
      nickname:'',birthDate:'2000-01-01T00:00:00.000',scores});
    assert.equal((await getDoc(ref)).data().name,'Integração');
    await sendPasswordResetEmail(auth,email);
    await signOut(auth);
    assert.equal(auth.currentUser,null);
    await assert.rejects(getDoc(ref));
    await assert.rejects(signInWithEmailAndPassword(auth,email,'senha-errada'));
    const login=await signInWithEmailAndPassword(auth,email,password);
    assert.equal(login.user.uid,uid);
    assert.equal((await getDoc(ref)).exists(),true);
    await assert.rejects(createUserWithEmailAndPassword(auth,email,password));
    await signOut(auth);
  } finally {
    await terminate(db);
    await deleteApp(app);
  }
});
