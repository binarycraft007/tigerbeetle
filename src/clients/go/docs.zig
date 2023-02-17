const Docs = @import("../docs_types.zig").Docs;

pub const GoDocs = Docs{
    .readme = "go/README.md",

    .markdown_name = "go",
    .extension = "go",

    .test_linux_docker_image = "golang:1.18",

    .name = "tigerbeetle-go",
    .description = 
    \\The TigerBeetle client for Go.
    \\
    \\[![Go Reference](https://pkg.go.dev/badge/github.com/tigerbeetledb/tigerbeetle-go.svg)](https://pkg.go.dev/github.com/tigerbeetledb/tigerbeetle-go)
    \\
    \\Make sure to import `github.com/tigerbeetledb/tigerbeetle-go`, not
    \\this repo and subdirectory.
    ,

    .prerequisites = 
    \\* Go >= 1.17
    ,

    .install_sample_file = 
    \\package main
    \\
    \\import _ "github.com/tigerbeetledb/tigerbeetle-go"
    \\import "fmt"
    \\
    \\func main() {
    \\  fmt.Println("Import ok!")
    \\}
    ,

    .install_commands = 
    \\go mod init tbtest
    \\go mod tidy
    ,

    .install_sample_file_build_commands = "go build test.go",
    .install_sample_file_test_commands = "go run test.go",

    .install_documentation = "",

    .examples = 
    \\## Basic
    \\
    \\See [./samples/basic](./samples/basic) for a Go project
    \\showing many features of the client.
    \\
    \\### Sidenote: `uint128`
    \\
    \\Throughout this README there will be a reference to a
    \\helper, `uint128`, that converts a string to TigerBeetle's
    \\representation of a 128-bit integer. That helper can be
    \\defined like so:
    \\
    \\```go
    \\func uint128(value string) tb_types.Uint128 {
    \\	x, err := tb_types.HexStringToUint128(value)
    \\	if err != nil {
    \\		panic(err)
    \\	}
    \\	return x
    \\}
    \\```
    ,

    .client_object_example = 
    \\client, err := tb.NewClient(0, []string{"3001", "3002", "3003"}, 1)
    \\if err != nil {
    \\	log.Printf("Error creating client: %s", err)
    \\	return
    \\}
    \\defer client.Close()
    ,

    .client_object_documentation = 
    \\The third argument to `NewClient` is a `uint` max concurrency
    \\setting. `1` is a good default and can increase to `4096`
    \\as you need increased throughput.
    ,

    .create_accounts_example = 
    \\accountsRes, err := client.CreateAccounts([]tb_types.Account{
    \\	{
    \\		ID:     	uint128("137"),
    \\		UserData:	tb_types.Uint128{},
    \\		Reserved:   	[48]uint8{},
    \\		Ledger:		1,
    \\		Code:   	718,
    \\		Flags:   	0,
    \\		DebitsPending: 	0,
    \\		DebitsPosted: 	0,
    \\		CreditsPending:	0,
    \\		CreditsPosted: 	0,
    \\		Timestamp: 	0,
    \\	},
    \\})
    \\if err != nil {
    \\	log.Printf("Error creating accounts: %s", err)
    \\	return
    \\}
    \\
    \\for _, err := range accountsRes {
    \\	log.Printf("Error creating account %d: %s", err.Index, err.Result)
    \\	return
    \\}
    ,

    .create_accounts_documentation = 
    \\The `tb_types` package can be imported from `"github.com/tigerbeetledb/tigerbeetle-go/pkg/types"`.
    ,

    .account_flags_documentation = 
    \\To toggle behavior for an account, use the `AccountFlags` struct
    \\to combine enum values and generate a `uint16`. Here are a
    \\few examples:
    \\
    \\* `AccountFlags{Linked: true}.ToUint16()`
    \\* `AccountFlags{DebitsMustNotExceedCredits: true}.ToUint16()`
    \\* `AccountFlags{CreditsMustNotExceedDebits: true}.ToUint16()`
    ,
    .account_flags_example =
\\account0 := tb_types.Account{ ... account values ... }
\\account1 := tb_types.Account{ ... account values ... }
\\account0.Flags = AccountFlags{Linked: true}.ToUint16()
\\accountErrors := client.CreateAccounts([]tb_types.Account{account0, account1})
        ,

    .create_accounts_errors_example = 
    \\res, err := client.CreateAccounts([]tb_types.Account{account1, account2, account3})
    \\if err != nil {
    \\	log.Printf("Error creating accounts: %s", err)
    \\	return
    \\}
    \\
    \\for _, err := range res {
    \\	log.Printf("Error creating account %d: %s", err.Index, err.Result)
    \\	return
    \\}
    ,

    .create_accounts_errors_documentation = 
    \\To handle errors you can either 1) exactly match error codes returned
    \\from `client.createAccounts` with enum values in the
    \\`CreateAccountError` object, or you can 2) look up the error code in
    \\the `CreateAccountError` object for a human-readable string.
    ,
    .lookup_accounts_example = 
    \\accounts, err := client.LookupAccounts([]tb_types.Uint128{uint128("137"), uint128("138")})
    \\if err != nil {
    \\	log.Printf("Could not fetch accounts: %s", err)
    \\	return
    \\}
    \\log.Println(accounts)
    ,

    .create_transfers_example = 
    \\transfer := tb_types.Transfer{
    \\	ID:			uint128("1"),
    \\	PendingID:		tb_types.Uint128{},
    \\	DebitAccountID:		uint128("1"),
    \\	CreditAccountID:	uint128("2"),
    \\	UserData:		uint128("2"),
    \\	Reserved:		tb_types.Uint128{},
    \\	Timeout:		0,
    \\	Ledger:			1,
    \\	Code:			1,
    \\	Flags:			0,
    \\	Amount:			10,
    \\	Timestamp:		0,
    \\}
    \\
    \\transfersRes, err := client.CreateTransfers([]tb_types.Transfer{transfer})
    \\if err != nil {
    \\	log.Printf("Error creating transfer batch: %s", err)
    \\	return
    \\}
    ,
    .create_transfers_documentation = "",
    .create_transfers_errors_example =
    \\for _, err := range transfersRes {
    \\	log.Printf("Batch transfer at %d failed to create: %s", err.Index, err.Result)
    \\	return
    \\}
    ,
    .create_transfers_errors_documentation = "",

    .no_batch_example = 
    \\for (let i = 0; i < len(transfers); i++) {
    \\  errors := client.CreateTransfers(transfers[i]);
    \\  // error handling omitted
    \\}
    ,

    .batch_example = 
    \\BATCH_SIZE := 8191
    \\for i := 0; i < len(transfers); i += BATCH_SIZE {
    \\  batch := BATCH_SIZE
    \\  if i + BATCH_SIZE > len(transfers) {
    \\    i = BATCH_SIZE - i
    \\  }
    \\  errors := client.CreateTransfers(transfers[i:i + batch])
    \\  // error handling omitted
    \\}
    ,

    .transfer_flags_documentation =
    \\To toggle behavior for an account, use the `TransferFlags` struct
    \\to combine enum values and generate a `uint16`. Here are a
    \\few examples:
    \\
    \\* `TransferFlags{Linked: true}.ToUint16()`
    \\* `TransferFlags{Pending: true}.ToUint16()`
    \\* `TransferFlags{PostPendingTransfer: true}.ToUint16()`
    \\* `TransferFlags{VoidPendingTransfer: true}.ToUint16()`
    ,
    .transfer_flags_link_example = "",
    .transfer_flags_post_example = "",
    .transfer_flags_void_example = "",

    .lookup_transfers_example = "",

    .linked_events_example = "",

    .developer_setup_bash_commands = 
    \\git clone https://github.com/tigerbeetledb/tigerbeetle
    \\cd tigerbeetle/src/clients/go
    \\./tigerbeetle/scripts/install_zig.sh
    \\./scripts/rebuild_binaries.sh
    \\./zgo test
    ,

    .developer_setup_windows_commands = 
    \\git clone https://github.com/tigerbeetledb/tigerbeetle
    \\cd tigerbeetle/src/clients/go
    \\./tigerbeetle/scripts/install_zig.bat
    \\./scripts/rebuild_binaries.sh
    \\./zgo.bat test
    ,

    .test_main_prefix = 
    \\package main
    \\
    \\import "log"
    \\
    \\import tb "github.com/tigerbeetledb/tigerbeetle-go"
    \\import tb_types "github.com/tigerbeetledb/tigerbeetle-go/pkg/types"
    \\
    \\func uint128(value string) tb_types.Uint128 {
    \\	x, err := tb_types.HexStringToUint128(value)
    \\	if err != nil {
    \\		panic(err)
    \\	}
    \\	return x
    \\}
    \\
    \\func main() {
    ,

    .test_main_suffix = "}",

    .code_format_commands = "gofmt -w -s *.go",
};
