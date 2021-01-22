#!/bin/sh
# Generate signed test fixtures

set -ex

cd "$(dirname "$0")"
didkit_dir=../../../../../didkit

print_json() {
	if command -v jq >/dev/null 2>&1; then
		jq .
	elif command -v json_pp >/dev/null 2>&1; then
		json_pp
	else
		cat
	fi
}

issuer1_jwk=$didkit_dir/cli/tests/ed25519-key.jwk
issuer2_jwk=$didkit_dir/http/tests/key.jwk

issuer1_did=$(didkit key-to-did-key -k "$issuer1_jwk")
issuer1_vmethod=$(didkit key-to-verification-method -k "$issuer1_jwk")

issuer2_did=$(didkit key-to-did-key -k "$issuer2_jwk")
issuer2_vmethod=$(didkit key-to-verification-method -k "$issuer2_jwk")

subject1_did='did:example:d23dd687a7dc6787646f2eb98d0'

# Issue VerifiableCredential-1
# issuer == subject

didkit vc-issue-credential -k "$issuer1_jwk" -v "$issuer1_vmethod" -p assertionMethod <<EOF | print_json > verifiable_credentials/VerifiableCredential-1.json
{
	"@context": ["https://www.w3.org/2018/credentials/v1"],
	"id": "urn:uuid:49372bc2-010a-4f73-b251-37da9b1e1366",
	"type": "VerifiableCredential",
	"issuer": "$issuer1_did",
	"issuanceDate": "2020-11-30T21:46:50Z",
	"credentialSubject": {
		"id": "$issuer1_did"
	}
}
EOF
didkit vc-verify-credential < verifiable_credentials/VerifiableCredential-1.json
echo

# Issue VerifiableCredential-2
# different issuer

didkit vc-issue-credential -k "$issuer2_jwk" -v "$issuer2_vmethod" -p assertionMethod <<EOF | print_json > verifiable_credentials/VerifiableCredential-2.json
{
	"@context": "https://www.w3.org/2018/credentials/v1",
	"id": "http://example.org/credentials/3731",
	"type": ["VerifiableCredential"],
	"issuer": "$issuer2_did",
	"issuanceDate": "2020-11-30T21:53:33Z",
	"credentialSubject": {
		"id": "$subject1_did"
	}
}
EOF
didkit vc-verify-credential < verifiable_credentials/VerifiableCredential-2.json
echo

# Prove case-1

# 1. The Verifier's Verify Presentation HTTP API MUST verify a Verifiable Presentation where the credential's issuer, presentation's holder and credential's subject are different.
didkit vc-issue-presentation -k "$issuer1_jwk" -v "$issuer1_vmethod" <<EOF | print_json > verifiable_presentations/case-1.json
{
  "@context": ["https://www.w3.org/2018/credentials/v1"],
  "id": "urn:uuid:354f00f2-02ec-470e-8c82-7e7d0fb679ed",
  "type": ["VerifiablePresentation"],
  "holder": "$issuer1_did",
  "verifiableCredential": [$(cat verifiable_credentials/VerifiableCredential-2.json)]
}
EOF
didkit vc-verify-presentation < verifiable_presentations/case-1.json
echo

# Prove case-2

# 2. The Verifier's Verify Presentation HTTP API MUST verify a Verifiable Presentation where the credential's issuer, presentation's holder and credential's subject are the same.

didkit vc-issue-presentation -k "$issuer1_jwk" -v "$issuer1_vmethod" -p authentication <<EOF | print_json > verifiable_presentations/case-2.json
{
  "@context": ["https://www.w3.org/2018/credentials/v1"],
  "id": "urn:uuid:ba318d78-3eb4-44be-a65c-54dd69847ee1",
  "type": ["VerifiablePresentation"],
  "holder": "$issuer1_did",
  "verifiableCredential": [$(cat verifiable_credentials/VerifiableCredential-1.json)]
}
EOF
didkit vc-verify-presentation < verifiable_presentations/case-2.json
echo
