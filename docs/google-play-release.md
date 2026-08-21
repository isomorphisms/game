# Google Play release boundary

This repository contains two distinct store applications on long-lived branches.
They must not share the old public development package or signing key.

| App | Source branch | Permanent package ID |
| --- | --- | --- |
| You Are a Cheetah | `cheetah` | `org.isomorphisms.cheetah` |
| Dress the Unicorn | `animal-salon` | `org.isomorphisms.dresstheunicorn` |

The `Google Play app bundles` workflow lives on `main`, checks out the selected
game branch, targets Android API 36, builds a signed Android App Bundle, and can
send it only to the Play internal-testing track. It never publishes directly to
production.

## GitHub environment and secrets

Create protected environments named `google-play-cheetah` and
`google-play-salon`. Store these secrets in each environment:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_KEYSTORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

The first four describe a private Play upload key, not either public development
key already committed for sideloaded previews. Godot currently requires the key
password and keystore password to be identical, so create the salon upload key
that way. The two environments keep each app's key and service-account access
separate while retaining the same secret names.

Enroll each app in Play App Signing. The private upload key signs the `.aab` sent
to Google; it is not the key Google uses to sign device APKs.

## One-time Play Console work

1. Create both applications with exactly the package IDs above.
2. Finish the required store listing, content, target-audience, data-safety, and
   testing declarations.
3. Run the workflow with `destination: artifact-only` and manually upload that
   first signed `.aab` in Play Console.
4. Enable the Google Play Developer API, grant the service account access to the
   corresponding app, and store its JSON credential.
5. Later runs may use `destination: internal-track`. Promote a checked build in
   Play Console rather than giving CI a production target.

Every upload needs a new integer `version_code`; Google Play never permits that
number to decrease or be reused. The user-visible `version_name` may follow the
ordinary release name.
