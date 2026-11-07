# AttendEase

Attendance tracker + CGPA calculator + exam syllabus checklist for students. Built with Flutter (web).
Data is saved in the browser (shared_preferences), so no backend is needed.

## Setup
```bash
flutter create attendease --platforms web
# copy this project's `lib/` folder and `pubspec.yaml` over the generated ones
cd attendease
flutter pub get
flutter run -d chrome
```

## Deploy on GitHub Pages
```bash
flutter build web --release --base-href "/YOUR-REPO-NAME/"
# push the contents of build/web to the gh-pages branch (or a /docs folder) and enable Pages
```

## Deploy on Vercel
```bash
flutter build web --release
# deploy the build/web folder (vercel build/web --prod)
```

## Grade scale (edit in lib/models/semester.dart)
O=10, A+=9, A=8, B+=7, B=6, C=5, F=0
