# Releasing Skedjewel

Release binaries are built by GitHub Actions from version tags. The workflow checks the binary version, generates a signed build provenance attestation, and creates the GitHub Release with the binary attached.

## Repository setup

Before the first release:

1. Enable [immutable releases](https://docs.github.com/en/code-security/concepts/supply-chain-security/immutable-releases) in the `davidrunger/skedjewel` repository settings. This is a GitHub repository setting; it cannot be enabled by committing a workflow file. New immutable releases lock their release-specific tags and assets and receive a signed release attestation.
2. Confirm that repository and organization policies allow `GITHUB_TOKEN` to write repository contents:
   1. Open the repository's [Actions settings](https://github.com/davidrunger/skedjewel/settings/actions).
   2. Select **Actions -> General**.
   3. Under **Workflow permissions**, select **Read and write permissions**.
   4. Click **Save**.

   If the repository is organization-owned, an organization owner must also check **Organization Settings -> Actions -> General -> Workflow permissions** and ensure that the organization is not enforcing read-only permissions. The release workflow requests `contents: write` to create the release, `id-token: write` to sign provenance with Sigstore, and `attestations: write` to publish the provenance attestation.

## Preparing a release

1. Update the `version` in `shard.yml`.
2. Add the release notes to `CHANGELOG.md` and move the notes out of `Unreleased` into a versioned section.
3. Commit and merge the version change to `main`.

The release tag must point to the commit containing the matching `shard.yml` version. The workflow checks that the compiled binary reports the version represented by the tag.

## Publishing a release

From a clean, up-to-date checkout of `main`, create and push the version tag:

```sh
TAG="v$(yq -r '.version' shard.yml)"
git tag "$TAG"
git push origin "$TAG"
```

Pushing a `v*` tag starts the Release workflow. It checks out that exact tag, builds the Linux binary, generates its build provenance attestation, and runs `gh release create` with the binary. When immutable releases are enabled, `gh release create` creates the release as a draft, uploads the binary, and publishes the release only after the asset is attached.

Do not create the GitHub Release manually before pushing the tag. The workflow must attach the binary before the immutable release is published.

If the workflow fails before publication, inspect the failure and rerun the workflow. Do not move a tag after its immutable release has been published; published immutable release tags and assets cannot be changed.
