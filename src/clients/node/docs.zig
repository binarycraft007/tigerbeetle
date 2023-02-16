const Docs = @import("../docs_types.zig").Docs;

pub const NodeDocs = Docs{
    .readme = "node/README.md",
    .markdown_name = "javascript",
    .extension = "js",
    .test_linux_docker_image = "node:18",
    .name = "tigerbeetle-node",
    .description = 
    \\The TigerBeetle client for Node.js.
    ,
    .prerequisites = 
    \\* NodeJS >= `14`. _(If the correct version is not installed, an installation error will occur)_
    \\
    \\> Your operating system should be Linux (kernel >= v5.6) or macOS.
    \\> Windows support is not yet available.
    ,

    .install_sample_file = 
    \\const { createClient } = require("tigerbeetle-node");
    \\console.log("Import ok!");
    ,

    .install_sample_file_build_commands = "npm install typescript @types/node && npx tsc --allowJs --noEmit test.js",
    .install_sample_file_test_commands = "node run test.js",
    .install_commands = "npm install tigerbeetle-node",
    .install_documentation = 
    \\If you run into issues, check out the distribution-specific install
    \\steps that are run in CI to test support:
    \\
    \\* [Alpine](./scripts/test_install_on_alpine.sh)
    \\* [Amazon Linux](./scripts/test_install_on_amazonlinux.sh)
    \\* [Debian](./scripts/test_install_on_debian.sh)
    \\* [Fedora](./scripts/test_install_on_fedora.sh)
    \\* [Ubuntu](./scripts/test_install_on_ubuntu.sh)
    \\* [RHEL](./scripts/test_install_on_rhelubi.sh)
    \\
    \\### Sidenote: `BigInt`
    \\TigerBeetle uses 64-bit integers for many fields while JavaScript's
    \\builtin `Number` maximum value is `2^53-1`. The `n` suffix in JavaScript
    \\means the value is a `BigInt`. This is useful for literal numbers. If
    \\you already have a `Number` variable though, you can call the `BigInt`
    \\constructor to get a `BigInt` from it. For example, `1n` is the same as
    \\`BigInt(1)`.
    ,
    .examples = "",
    .no_batch_example = 
    \\for (let i = 0; i < transfers.len; i++) {
    \\  const transferErrors = client.createTransfers(transfers[i]);
    \\  // error handling omitted
    \\}
    ,
    .batch_example = 
    \\const BATCH_SIZE = 8191;
    \\for (let i = 0; i < transfers.length; i += BATCH_SIZE) {
    \\  const transferErrors = client.createTransfers(transfers.slice(i, Math.min(transfers.length, BATCH_SIZE)));
    \\  // error handling omitted
    \\}
    ,
    .client_object_example = 
    \\const client = createClient({
    \\  cluster_id: 0,
    \\  replica_addresses: ['3001', '3002', '3003']
    \\});
    ,
    .client_object_documentation = "",
    .create_accounts_example = 
    \\const account = {
    \\  id: 137n, // u128
    \\  user_data: 0n, // u128, opaque third-party identifier to link this account to an external entity:
    \\  reserved: Buffer.alloc(48, 0), // [48]u8
    \\  ledger: 1,   // u32, ledger value
    \\  code: 718, // u16, a chart of accounts code describing the type of account (e.g. clearing, settlement)
    \\  flags: 0,  // u16
    \\  debits_pending: 0n,  // u64
    \\  debits_posted: 0n,  // u64
    \\  credits_pending: 0n, // u64
    \\  credits_posted: 0n, // u64
    \\  timestamp: 0n, // u64, Reserved: This will be set by the server.
    \\};
    \\
    \\const accountErrors = await client.createAccounts([account]);
    \\if (accountErrors.length) {
    \\  // Grab a human-readable message from the response
    \\  console.log(CreateAccountError[accountErrors[0].code]);
    \\}
    ,
    .create_accounts_documentation = "",
    .account_flags_details = 
    \\To toggle behavior for an account, combine enum values stored in the
    \\`AccountFlags` object (in TypeScript it is an actual enum) with
    \\bitwise-or:
    \\
    \\* `AccountFlags.linked`
    \\* `AccountFlags.debits_must_not_exceed_credits`
    \\* `AccountFlags.credits_must_not_exceed_credits`
    \\
    ,

    .account_flags_example = 
    \\const account0 = { ... account values ... };
    \\const account1 = { ... account values ... };
    \\account0.flags = AccountFlags.linked | AccountFlags.debits_must_not_exceed_credits;
    \\// Create the account
    \\const accountErrors = client.createAccounts([account0, account1]);
    ,
    .create_accounts_errors_example = 
    \\const accountErrors = await client.createAccounts([account1, account2, account3]);
    \\
    \\// accountErrors = [{ index: 1, code: 1 }];
    \\for (const error of accountErrors) {
    \\  switch (error.code) {
    \\    case CreateAccountError.exists:
    \\      console.error(`Batch account at ${error.index} already exists.`);
    \\	  break;
    \\    default:
    \\      console.error(`Batch account at ${error.index} failed to create: ${CreateAccountError[error.code]}.`);
    \\  }
    \\}
    ,
    .create_accounts_errors_documentation = 
    \\To handle errors you can either 1) exactly match error codes returned
    \\from `client.createAccounts` with enum values in the
    \\`CreateAccountError` object, or you can 2) look up the error code in
    \\the `CreateAccountError` object for a human-readable string.
    ,
    .lookup_accounts_example = 
    \\// account 137n exists, 138n does not
    \\const accounts = await client.lookupAccounts([137n, 138n]);
    \\/* console.log(accounts);
    \\ * [{
    \\ *   id: 137n,
    \\ *   user_data: 0n,
    \\ *   reserved: Buffer,
    \\ *   ledger: 1,
    \\ *   code: 718,
    \\ *   flags: 0,
    \\ *   debits_pending: 0n,
    \\ *   debits_posted: 0n,
    \\ *   credits_pending: 0n,
    \\ *   credits_posted: 0n,
    \\ *   timestamp: 1623062009212508993n,
    \\ * }]
    \\ */
    ,

    .create_transfers_example = 
    \\const transfer = {
    \\  id: 1n, // u128
    \\  pending_id: 0n, // u128
    \\  // Double-entry accounting:
    \\  debit_account_id: 1n,  // u128
    \\  credit_account_id: 2n, // u128
    \\  // Opaque third-party identifier to link this transfer to an external entity:
    \\  user_data: 0n, // u128  
    \\  reserved: 0n, // u128
    \\  // Timeout applicable for a pending/2-phase transfer:
    \\  timeout: 0n, // u64, in nano-seconds.
    \\  // Collection of accounts usually grouped by the currency: 
    \\  // You can't transfer money between accounts with different ledgers:
    \\  ledger: 1,  // u32, ledger for transfer (e.g. currency).
    \\  // Chart of accounts code describing the reason for the transfer:
    \\  code: 720,  // u16, (e.g. deposit, settlement)
    \\  flags: 0, // u16
    \\  amount: 10n, // u64
    \\  timestamp: 0n, //u64, Reserved: This will be set by the server.
    \\};
    \\const transferErrors = await client.createTransfers([transfer]);
    \\for (const error of transferErrors) {
    \\  switch (error.code) {
    \\    default:
    \\      console.error(`Batch transfer at ${error.index} failed to create: ${CreateAccountError[error.code]}.`);
    \\  }
    \\}
    ,
    .create_transfers_documentation = "",
    .create_transfers_errors_example = 
    \\const transferErrors = await client.createTransfers([transfer1, transfer2, transfer3]);
    \\
    \\// transferErrors = [{ index: 1, code: 1 }];
    \\for (const error of transferErrors) {
    \\  switch (error.code) {
    \\    case CreateTransferError.exists:
    \\      console.error(`Batch transfer at ${error.index} already exists.`);
    \\	  break;
    \\    default:
    \\      console.error(`Batch transfer at ${error.index} failed to create: ${CreateTransferError[error.code]}.`);
    \\  }
    \\}
    ,
    .create_transfers_errors_documentation = 
    \\To handle errors you can either 1) exactly match error codes returned
    \\from `client.createTransfers` with enum values in the
    \\`CreateTransferError` object, or you can 2) look up the error code in
    \\the `CreateTransferError` object for a human-readable string.
    ,
    .developer_setup_bash_commands = 
    \\npm install --include dev # This will automatically install and build everything you need.
    ,
    .developer_setup_windows_commands = 
    \\npm install --include dev # This will automatically install and build everything you need.
    ,
    .test_main_prefix = 
    \\const { createClient } = require("tigerbeetle-node");
    \\
    \\async function main() {
    ,
    .test_main_suffix = 
    \\}
    \\main().then(() => process.exit(0)).catch((e) => { console.error(e); process.exit(1); });
    ,
    .code_format_commands = "npm install prettier && npx prettier --write .",
};
