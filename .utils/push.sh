
VERSION="1.0.0"
REPO=https://github.com/angelespejo/apple-notes-cli
ACTUAL_VERSION=$(grep '^VERSION=' $VERSION | awk -F '=' '{print $2}')

read -p "Add files for git: (default: .)" git_add
read -p "Set release commit (default: 'Release commit 🌈⚡️'): " git_commit
read -p "Actual version is ${ACTUAL_VERSION}. Change to another: (default: false)" version

version=${version:-"false"}
git_add=${git_add:-"."}
git_commit=${git_commit:-"Release commit 🌈⚡️"}


if [[ $version != false ]]; then

	echo "Add version '${version}' to file: $VERSION"
	sed -i '' "s/VERSION=\".*\"/VERSION=\"${version}\"/" "$VERSION"
	echo "version changed to ${version}"
	
	echo "Add tag v${version}"
	git tag -a "v${version}" -m "${git_commit}"
	
	echo "Add release v${version}"
	gh release create "v${version}" --title "${version}" --notes "📜 LICENSE: ${REPO}/blob/main/LICENSE"
	
	echo "Add asset to release: v${version}"
	bash build.sh
	gh release upload "v${version}" ./dist/umac.zip

fi

gh repo edit $REPO -d '🗒️🍎🐢 Manage MacOS Notes via cli: add, remove, check etc...'
gh repo edit $REPO --add-topic macos,shell,bash,apple,terminal,applescript,darwin

git add $git_add
git commit -m "$git_commit"
git push --follow-tags origin main