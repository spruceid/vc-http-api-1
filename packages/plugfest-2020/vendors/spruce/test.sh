#!/bin/sh
cd "$(dirname "$0")"
rm -f */.*.json.sw* # remove vim swap files
didkit_dir=../../../../../didkit
cargo build --manifest-path $didkit_dir/http/Cargo.toml || exit 1
cargo run --manifest-path $didkit_dir/http/Cargo.toml -- -p 9999 \
	-k $didkit_dir/cli/tests/ed25519-key.jwk \
	-k $didkit_dir/http/tests/key.jwk \
	& pid=$!
npm run test:spruce
kill $pid
