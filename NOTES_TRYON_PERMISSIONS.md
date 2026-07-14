# Color Try-On — permissions natives à ajouter

Ce projet livré ne contient que le dossier `lib/` (pas de dossiers
`android/` ni `ios/`). Une fois ces dossiers générés (`flutter create .`)
ou dans votre projet natif existant, ajoutez les entrées suivantes pour
que la caméra, la galerie et l'enregistrement d'image fonctionnent.

## iOS — `ios/Runner/Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>MASTER SUD a besoin d'accéder à l'appareil photo pour photographier votre mur et essayer une couleur.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>MASTER SUD a besoin d'accéder à vos photos pour choisir une image de votre pièce.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>MASTER SUD a besoin d'accéder à vos photos pour enregistrer l'image avec la couleur essayée.</string>
```

## Android — `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />

<!-- Android 12 et versions antérieures : nécessaire pour enregistrer
     l'image dans la galerie. Le package `gal` gère lui-même la demande
     d'autorisation à l'exécution. -->
<uses-permission
    android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />

<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

Aucune de ces permissions n'est demandée au démarrage de l'application :
`image_picker` déclenche la demande caméra/photos uniquement au moment où
l'utilisateur choisit "Caméra" ou "Mes fichiers", et `gal` déclenche la
demande d'accès aux photos uniquement au moment d'appuyer sur
"Enregistrer".
