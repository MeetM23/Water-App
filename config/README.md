# Build configuration

Two files decide which Supabase project a build talks to. Neither is committed;
copy the matching `.example` and fill it in.

    cp config/dev.json.example  config/dev.json
    cp config/prod.json.example config/prod.json

Nothing in these files is secret. The anon key is a public, RLS-scoped client
key — every rule that protects the data lives in `supabase/migrations`, not in
the key. They are git-ignored because the project *ref* identifies a specific
database, and because a `prod.json` sitting in a pull request is an invitation
to point a test build at the client's live data.

**The `service_role` key must never appear in either file.** It bypasses row
level security completely, and anything placed here is compiled into an APK
that anybody can unzip.

## Why two switches

`--flavor` picks the Android application id and the app name.
`--dart-define-from-file` picks the Supabase project.

Nothing in the toolchain ties the two together, so the failure they invite is a
build labelled `prod`, installed over the client's app, quietly writing into the
development database. `Env.isFlavorConsistent` compares the two at startup and
refuses to run the app if they disagree, which turns that silent fault into a
screen you cannot miss.

## Commands

Run against development:

    flutter run --flavor dev --dart-define-from-file=config/dev.json

Release APK for direct install (one universal APK, all ABIs):

    flutter build apk --release --flavor prod \
      --dart-define-from-file=config/prod.json

App bundle for Play:

    flutter build appbundle --release --flavor prod \
      --dart-define-from-file=config/prod.json

The equivalents for the development flavour swap `prod` for `dev` in both
places. See README.md for the full release checklist.
