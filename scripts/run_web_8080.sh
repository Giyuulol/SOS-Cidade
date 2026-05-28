#!/usr/bin/env bash
# Script para iniciar o app Flutter no web-server sempre usando a porta 8080
flutter pub get
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080
