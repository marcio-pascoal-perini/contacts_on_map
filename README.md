# Contacts On Map

### Feactures:

##### The app reads the contact list in the mobile where it is installed and selects the contacts that contain addresses. Then uses the Google Geocoding API to get the coordinates of these addresses and includes them as markers with contacts' avatars on the app map.

### Comments:

#### Report the Google API Key in the code of the following files:

##### contacts_on_map/android/app/src/main/AndroidManifest.xml

```
<meta-data android:name="com.google.android.geo.API_KEY"
android:value="YOUR API KEY" />
```

##### contacts_on_map/ios/Runner/AppDelegate.swift

```
GMSServices.provideAPIKey("YOUR API KEY")
```

##### contacts_on_map/lib/geocoding_api.dart

```
const String _key = 'YOUR API KEY';
```

#### You will need to activate the following libraries:

- ##### Maps SDK for Android
- ##### Maps SDK for iOS
- ##### Geocoding API
