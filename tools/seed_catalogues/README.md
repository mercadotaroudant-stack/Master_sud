# Seed — Catalogues initiaux

Ce dossier contient un script Node.js (Firebase Admin SDK) qui crée les
9 catalogues initiaux dans Firestore, collection `paintCatalogues`, afin
que le Dashboard puisse ensuite les gérer (nom, image de couverture,
couleurs, ordre, actif/inactif).

Aucune image de couverture ni couleur n'est créée par ce script — elles
restent `null` / vides jusqu'à ce qu'elles soient ajoutées depuis le
Dashboard, comme demandé.

## Catalogues créés

1. Omega Jawaher
2. Omega Classic
3. Stuc Marmara
4. Top Safari
5. Safari
6. Master Isto
7. Master Bois
8. Omega Flora
9. Couleurs à l'huile et à l'eau

## Utilisation

```bash
cd tools/seed_catalogues
npm install
```

Récupérez une clé de compte de service Firebase :
Firebase Console → Paramètres du projet → Comptes de service → Générer
une nouvelle clé privée. Enregistrez le fichier téléchargé sous le nom
`service-account.json` dans ce même dossier (`tools/seed_catalogues/`).

Puis lancez :

```bash
node seed_catalogues.js
```

Le script est idempotent (basé sur le nom du catalogue) : le relancer ne
crée pas de doublons.

⚠️ Ne committez jamais `service-account.json` dans le dépôt Git — il
donne un accès administrateur complet à votre projet Firebase.
