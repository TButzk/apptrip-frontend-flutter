# AppTrip Flutter

Cliente Flutter multiplataforma para Android, iOS e Web consumindo o backend Java em `backend-java`.

## Pre-requisitos

- Flutter SDK. Neste repositório foi instalado um SDK local em `../.tools/flutter`.
- Backend Java rodando em `http://localhost:5010`.
- Para Android, use JDK compatível com o Gradle do Flutter. O SDK avisou que Java 25 pode conflitar; prefira Java 17 ou 21 para builds Android.

## Comandos

```powershell
cd apptrip-frontend-flutter
..\.tools\flutter\bin\flutter.bat pub get
..\.tools\flutter\bin\flutter.bat analyze
..\.tools\flutter\bin\flutter.bat test
```

Rodar Web usando uma porta liberada no CORS atual do backend:

```powershell
..\.tools\flutter\bin\flutter.bat run -d chrome --web-port 19006
```

Rodar Android no emulador:

```powershell
..\.tools\flutter\bin\flutter.bat run -d android
```

## Configuracao da API

O app aceita `API_BASE_URL` via `--dart-define`.

```powershell
..\.tools\flutter\bin\flutter.bat run -d chrome --web-port 19006 --dart-define=API_BASE_URL=http://localhost:5010/api/v1
```

Defaults:

- Android emulator: `http://10.0.2.2:5010/api/v1`
- Web/iOS simulator: `http://localhost:5010/api/v1`
- Celular fisico: informe o IPv4 do computador com `--dart-define=API_BASE_URL=http://SEU_IP:5010/api/v1`
