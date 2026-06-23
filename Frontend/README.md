# staydesk frontend

Flutter admin client for the `staydesk` booking dashboard.

## Run

```bash
flutter pub get
flutter run
```

## Configure API Base URL

```bash
flutter run --dart-define=STAYDESK_API_BASE_URL=http://localhost:5225/api
```

If no override is supplied, the app uses `http://localhost:5225/api`.

## Notes

- Authentication state is stored locally with `shared_preferences`
- The UI is built with `provider`
- Platform metadata has been renamed from Flutter defaults, but the generated platform scaffolding remains structurally standard
