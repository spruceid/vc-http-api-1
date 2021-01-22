'use strict';

const credentials = require('./credentials');
const verifiable_credentials = require('./verifiable_credentials');
const verifiable_presentations = require('./verifiable_presentations');

module.exports = {
  name: 'Spruce',
  // eslint-disable-next-line max-len
  verify_credential_endpoint: 'http://localhost:9999/verify/credentials',
  // eslint-disable-next-line max-len
  verify_presentation_endpoint: 'http://localhost:9999/verify/presentations',
  credentials: [...credentials],
  verifiable_credentials: [...verifiable_credentials],
  verifiable_presentations: [...verifiable_presentations],
  issuers: [
    {
      name: 'DID Key Issuer',
      endpoint: 'http://localhost:9999/issue/credentials',
      options: [
        {
          // eslint-disable-next-line max-len
          verificationMethod: 'did:key:z6MkiVpwA241guqtKWAkohHpcAry7S94QQb6ukW3GcCsugbK#z6MkiVpwA241guqtKWAkohHpcAry7S94QQb6ukW3GcCsugbK',
        },
        {
          // eslint-disable-next-line max-len
          verificationMethod: 'did:key:z6MkgYAGxLBSXa6Ygk1PnUbK2F7zya8juE9nfsZhrvY7c9GD#z6MkgYAGxLBSXa6Ygk1PnUbK2F7zya8juE9nfsZhrvY7c9GD',
        },
      ],
    },
  ],
};
