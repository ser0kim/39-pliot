#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
TASK_TEST_DIR=$(mktemp -d /tmp/life-sidequest-tests.XXXXXX)
trap 'rm -rf "$TASK_TEST_DIR"' EXIT
xcrun swiftc -parse-as-library -target arm64-apple-macos14.0 \
 Life-SideQuest/Domain/Entities/Adventure.swift \
 Life-SideQuest/Domain/Repositories/AdventureRepository.swift \
 Life-SideQuest/Domain/UseCases/AdventureRules.swift \
 Life-SideQuest/Domain/UseCases/QuestGenerator.swift \
 Life-SideQuest/Data/Repositories/LocalAdventureRepository.swift \
 Life-SideQuest/Presentation/Shared/AdventureSession.swift \
 Tests/AdventureRulesTests.swift Tests/QuestGenerationTests.swift -o "$TASK_TEST_DIR/test-core"
"$TASK_TEST_DIR/test-core"
