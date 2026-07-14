/**
 * Seed script — crée les 9 catalogues initiaux dans Firestore
 * (collection: paintCatalogues), sans image de couverture ni couleurs,
 * afin que le Dashboard puisse ensuite les compléter.
 *
 * Ce script ne crée AUCUNE couleur, AUCUNE image factice et n'invente
 * aucune donnée : seuls les noms des catalogues et leur ordre d'affichage
 * sont renseignés, exactement comme demandé.
 *
 * UTILISATION :
 *   1. cd tools/seed_catalogues
 *   2. npm install
 *   3. Placer votre clé de compte de service Firebase (JSON) à côté de ce
 *      fichier et la nommer `service-account.json`
 *      (Firebase Console > Paramètres du projet > Comptes de service >
 *      Générer une nouvelle clé privée)
 *   4. node seed_catalogues.js
 *
 * Le script est idempotent : le relancer ne duplique pas les catalogues
 * déjà créés (il utilise le nom comme identifiant de document, en le
 * "slugifiant").
 */

const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const CATALOGUE_NAMES = [
  'Omega Jawaher',
  'Omega Classic',
  'Stuc Marmara',
  'Top Safari',
  'Safari',
  'Master Isto',
  'Master Bois',
  'Omega Flora',
  "Couleurs à l'huile et à l'eau",
];

function slugify(name) {
  return name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
}

async function seed() {
  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  CATALOGUE_NAMES.forEach((name, index) => {
    const docRef = db.collection('paintCatalogues').doc(slugify(name));
    batch.set(
      docRef,
      {
        name,
        coverImageUrl: null,
        isActive: true,
        order: index + 1,
        createdAt: now,
        updatedAt: now,
      },
      { merge: true },
    );
  });

  await batch.commit();
  console.log(`Seeded ${CATALOGUE_NAMES.length} catalogues into "paintCatalogues".`);
}

seed()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Seed failed:', err);
    process.exit(1);
  });
