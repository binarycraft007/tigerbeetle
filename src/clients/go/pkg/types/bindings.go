///////////////////////////////////////////////////////
// This file was auto-generated by go_bindings.zig   //
//              Do not manually modify.              //
///////////////////////////////////////////////////////

package types

/*
#include "../native/tb_client.h"
*/
import "C"
import "strconv"

type AccountFlags struct {
	Linked                     bool
	DebitsMustNotExceedCredits bool
	CreditsMustNotExceedDebits bool
}

func (f AccountFlags) ToUint16() uint16 {
	var ret uint16 = 0

	if f.Linked {
		ret |= (1 << 0)
	}

	if f.DebitsMustNotExceedCredits {
		ret |= (1 << 1)
	}

	if f.CreditsMustNotExceedDebits {
		ret |= (1 << 2)
	}

	return ret
}

type TransferFlags struct {
	Linked              bool
	Pending             bool
	PostPendingTransfer bool
	VoidPendingTransfer bool
}

func (f TransferFlags) ToUint16() uint16 {
	var ret uint16 = 0

	if f.Linked {
		ret |= (1 << 0)
	}

	if f.Pending {
		ret |= (1 << 1)
	}

	if f.PostPendingTransfer {
		ret |= (1 << 2)
	}

	if f.VoidPendingTransfer {
		ret |= (1 << 3)
	}

	return ret
}

type Account struct {
	ID             Uint128
	UserData       Uint128
	Reserved       [48]uint8
	Ledger         uint32
	Code           uint16
	Flags          uint16
	DebitsPending  uint64
	DebitsPosted   uint64
	CreditsPending uint64
	CreditsPosted  uint64
	Timestamp      uint64
}

type Transfer struct {
	ID              Uint128
	DebitAccountID  Uint128
	CreditAccountID Uint128
	UserData        Uint128
	Reserved        Uint128
	PendingID       Uint128
	Timeout         uint64
	Ledger          uint32
	Code            uint16
	Flags           uint16
	Amount          uint64
	Timestamp       uint64
}

type CreateAccountResult uint32

const (
	AccountOK                          CreateAccountResult = 0
	AccountLinkedEventFailed           CreateAccountResult = 1
	AccountLinkedEventChainOpen        CreateAccountResult = 2
	AccountTimestampMustBeZero         CreateAccountResult = 3
	AccountReservedFlag                CreateAccountResult = 4
	AccountReservedField               CreateAccountResult = 5
	AccountIDMustNotBeZero             CreateAccountResult = 6
	AccountIDMustNotBeIntMax           CreateAccountResult = 7
	AccountLedgerMustNotBeZero         CreateAccountResult = 8
	AccountCodeMustNotBeZero           CreateAccountResult = 9
	AccountDebitsPendingMustBeZero     CreateAccountResult = 10
	AccountDebitsPostedMustBeZero      CreateAccountResult = 11
	AccountCreditsPendingMustBeZero    CreateAccountResult = 12
	AccountCreditsPostedMustBeZero     CreateAccountResult = 13
	AccountMutuallyExclusiveFlags      CreateAccountResult = 14
	AccountExistsWithDifferentFlags    CreateAccountResult = 15
	AccountExistsWithDifferentUserData CreateAccountResult = 16
	AccountExistsWithDifferentLedger   CreateAccountResult = 17
	AccountExistsWithDifferentCode     CreateAccountResult = 18
	AccountExists                      CreateAccountResult = 19
)

func (i CreateAccountResult) String() string {
	switch i {
	case AccountOK:
		return "AccountOK"
	case AccountLinkedEventFailed:
		return "AccountLinkedEventFailed"
	case AccountLinkedEventChainOpen:
		return "AccountLinkedEventChainOpen"
	case AccountTimestampMustBeZero:
		return "AccountTimestampMustBeZero"
	case AccountReservedFlag:
		return "AccountReservedFlag"
	case AccountReservedField:
		return "AccountReservedField"
	case AccountIDMustNotBeZero:
		return "AccountIDMustNotBeZero"
	case AccountIDMustNotBeIntMax:
		return "AccountIDMustNotBeIntMax"
	case AccountLedgerMustNotBeZero:
		return "AccountLedgerMustNotBeZero"
	case AccountCodeMustNotBeZero:
		return "AccountCodeMustNotBeZero"
	case AccountDebitsPendingMustBeZero:
		return "AccountDebitsPendingMustBeZero"
	case AccountDebitsPostedMustBeZero:
		return "AccountDebitsPostedMustBeZero"
	case AccountCreditsPendingMustBeZero:
		return "AccountCreditsPendingMustBeZero"
	case AccountCreditsPostedMustBeZero:
		return "AccountCreditsPostedMustBeZero"
	case AccountMutuallyExclusiveFlags:
		return "AccountMutuallyExclusiveFlags"
	case AccountExistsWithDifferentFlags:
		return "AccountExistsWithDifferentFlags"
	case AccountExistsWithDifferentUserData:
		return "AccountExistsWithDifferentUserData"
	case AccountExistsWithDifferentLedger:
		return "AccountExistsWithDifferentLedger"
	case AccountExistsWithDifferentCode:
		return "AccountExistsWithDifferentCode"
	case AccountExists:
		return "AccountExists"
	}
	return "CreateAccountResult(" + strconv.FormatInt(int64(i+1), 10) + ")"
}

type CreateTransferResult uint32

const (
	TransferOK                                         CreateTransferResult = 0
	TransferLinkedEventFailed                          CreateTransferResult = 1
	TransferLinkedEventChainOpen                       CreateTransferResult = 2
	TransferTimestampMustBeZero                        CreateTransferResult = 3
	TransferReservedFlag                               CreateTransferResult = 4
	TransferReservedField                              CreateTransferResult = 5
	TransferIDMustNotBeZero                            CreateTransferResult = 6
	TransferIDMustNotBeIntMax                          CreateTransferResult = 7
	TransferDebitAccountIDMustNotBeZero                CreateTransferResult = 8
	TransferDebitAccountIDMustNotBeIntMax              CreateTransferResult = 9
	TransferCreditAccountIDMustNotBeZero               CreateTransferResult = 10
	TransferCreditAccountIDMustNotBeIntMax             CreateTransferResult = 11
	TransferAccountsMustBeDifferent                    CreateTransferResult = 12
	TransferPendingIDMustBeZero                        CreateTransferResult = 13
	TransferLedgerMustNotBeZero                        CreateTransferResult = 14
	TransferCodeMustNotBeZero                          CreateTransferResult = 15
	TransferAmountMustNotBeZero                        CreateTransferResult = 16
	TransferDebitAccountNotFound                       CreateTransferResult = 17
	TransferCreditAccountNotFound                      CreateTransferResult = 18
	TransferAccountsMustHaveTheSameLedger              CreateTransferResult = 19
	TransferTransferMustHaveTheSameLedgerAsAccounts    CreateTransferResult = 20
	TransferExistsWithDifferentFlags                   CreateTransferResult = 21
	TransferExistsWithDifferentDebitAccountID          CreateTransferResult = 22
	TransferExistsWithDifferentCreditAccountID         CreateTransferResult = 23
	TransferExistsWithDifferentUserData                CreateTransferResult = 24
	TransferExistsWithDifferentPendingID               CreateTransferResult = 25
	TransferExistsWithDifferentTimeout                 CreateTransferResult = 26
	TransferExistsWithDifferentCode                    CreateTransferResult = 27
	TransferExistsWithDifferentAmount                  CreateTransferResult = 28
	TransferExists                                     CreateTransferResult = 29
	TransferOverflowsDebitsPending                     CreateTransferResult = 30
	TransferOverflowsCreditsPending                    CreateTransferResult = 31
	TransferOverflowsDebitsPosted                      CreateTransferResult = 32
	TransferOverflowsCreditsPosted                     CreateTransferResult = 33
	TransferOverflowsDebits                            CreateTransferResult = 34
	TransferOverflowsCredits                           CreateTransferResult = 35
	TransferOverflowsTimeout                           CreateTransferResult = 36
	TransferExceedsCredits                             CreateTransferResult = 37
	TransferExceedsDebits                              CreateTransferResult = 38
	TransferCannotPostAndVoidPendingTransfer           CreateTransferResult = 39
	TransferPendingTransferCannotPostOrVoidAnother     CreateTransferResult = 40
	TransferTimeoutReservedForPendingTransfer          CreateTransferResult = 41
	TransferPendingIDMustNotBeZero                     CreateTransferResult = 42
	TransferPendingIDMustNotBeIntMax                   CreateTransferResult = 43
	TransferPendingIDMustBeDifferent                   CreateTransferResult = 44
	TransferPendingTransferNotFound                    CreateTransferResult = 45
	TransferPendingTransferNotPending                  CreateTransferResult = 46
	TransferPendingTransferHasDifferentDebitAccountID  CreateTransferResult = 47
	TransferPendingTransferHasDifferentCreditAccountID CreateTransferResult = 48
	TransferPendingTransferHasDifferentLedger          CreateTransferResult = 49
	TransferPendingTransferHasDifferentCode            CreateTransferResult = 50
	TransferExceedsPendingTransferAmount               CreateTransferResult = 51
	TransferPendingTransferHasDifferentAmount          CreateTransferResult = 52
	TransferPendingTransferAlreadyPosted               CreateTransferResult = 53
	TransferPendingTransferAlreadyVoided               CreateTransferResult = 54
	TransferPendingTransferExpired                     CreateTransferResult = 55
)

func (i CreateTransferResult) String() string {
	switch i {
	case TransferOK:
		return "TransferOK"
	case TransferLinkedEventFailed:
		return "TransferLinkedEventFailed"
	case TransferLinkedEventChainOpen:
		return "TransferLinkedEventChainOpen"
	case TransferTimestampMustBeZero:
		return "TransferTimestampMustBeZero"
	case TransferReservedFlag:
		return "TransferReservedFlag"
	case TransferReservedField:
		return "TransferReservedField"
	case TransferIDMustNotBeZero:
		return "TransferIDMustNotBeZero"
	case TransferIDMustNotBeIntMax:
		return "TransferIDMustNotBeIntMax"
	case TransferDebitAccountIDMustNotBeZero:
		return "TransferDebitAccountIDMustNotBeZero"
	case TransferDebitAccountIDMustNotBeIntMax:
		return "TransferDebitAccountIDMustNotBeIntMax"
	case TransferCreditAccountIDMustNotBeZero:
		return "TransferCreditAccountIDMustNotBeZero"
	case TransferCreditAccountIDMustNotBeIntMax:
		return "TransferCreditAccountIDMustNotBeIntMax"
	case TransferAccountsMustBeDifferent:
		return "TransferAccountsMustBeDifferent"
	case TransferPendingIDMustBeZero:
		return "TransferPendingIDMustBeZero"
	case TransferLedgerMustNotBeZero:
		return "TransferLedgerMustNotBeZero"
	case TransferCodeMustNotBeZero:
		return "TransferCodeMustNotBeZero"
	case TransferAmountMustNotBeZero:
		return "TransferAmountMustNotBeZero"
	case TransferDebitAccountNotFound:
		return "TransferDebitAccountNotFound"
	case TransferCreditAccountNotFound:
		return "TransferCreditAccountNotFound"
	case TransferAccountsMustHaveTheSameLedger:
		return "TransferAccountsMustHaveTheSameLedger"
	case TransferTransferMustHaveTheSameLedgerAsAccounts:
		return "TransferTransferMustHaveTheSameLedgerAsAccounts"
	case TransferExistsWithDifferentFlags:
		return "TransferExistsWithDifferentFlags"
	case TransferExistsWithDifferentDebitAccountID:
		return "TransferExistsWithDifferentDebitAccountID"
	case TransferExistsWithDifferentCreditAccountID:
		return "TransferExistsWithDifferentCreditAccountID"
	case TransferExistsWithDifferentUserData:
		return "TransferExistsWithDifferentUserData"
	case TransferExistsWithDifferentPendingID:
		return "TransferExistsWithDifferentPendingID"
	case TransferExistsWithDifferentTimeout:
		return "TransferExistsWithDifferentTimeout"
	case TransferExistsWithDifferentCode:
		return "TransferExistsWithDifferentCode"
	case TransferExistsWithDifferentAmount:
		return "TransferExistsWithDifferentAmount"
	case TransferExists:
		return "TransferExists"
	case TransferOverflowsDebitsPending:
		return "TransferOverflowsDebitsPending"
	case TransferOverflowsCreditsPending:
		return "TransferOverflowsCreditsPending"
	case TransferOverflowsDebitsPosted:
		return "TransferOverflowsDebitsPosted"
	case TransferOverflowsCreditsPosted:
		return "TransferOverflowsCreditsPosted"
	case TransferOverflowsDebits:
		return "TransferOverflowsDebits"
	case TransferOverflowsCredits:
		return "TransferOverflowsCredits"
	case TransferOverflowsTimeout:
		return "TransferOverflowsTimeout"
	case TransferExceedsCredits:
		return "TransferExceedsCredits"
	case TransferExceedsDebits:
		return "TransferExceedsDebits"
	case TransferCannotPostAndVoidPendingTransfer:
		return "TransferCannotPostAndVoidPendingTransfer"
	case TransferPendingTransferCannotPostOrVoidAnother:
		return "TransferPendingTransferCannotPostOrVoidAnother"
	case TransferTimeoutReservedForPendingTransfer:
		return "TransferTimeoutReservedForPendingTransfer"
	case TransferPendingIDMustNotBeZero:
		return "TransferPendingIDMustNotBeZero"
	case TransferPendingIDMustNotBeIntMax:
		return "TransferPendingIDMustNotBeIntMax"
	case TransferPendingIDMustBeDifferent:
		return "TransferPendingIDMustBeDifferent"
	case TransferPendingTransferNotFound:
		return "TransferPendingTransferNotFound"
	case TransferPendingTransferNotPending:
		return "TransferPendingTransferNotPending"
	case TransferPendingTransferHasDifferentDebitAccountID:
		return "TransferPendingTransferHasDifferentDebitAccountID"
	case TransferPendingTransferHasDifferentCreditAccountID:
		return "TransferPendingTransferHasDifferentCreditAccountID"
	case TransferPendingTransferHasDifferentLedger:
		return "TransferPendingTransferHasDifferentLedger"
	case TransferPendingTransferHasDifferentCode:
		return "TransferPendingTransferHasDifferentCode"
	case TransferExceedsPendingTransferAmount:
		return "TransferExceedsPendingTransferAmount"
	case TransferPendingTransferHasDifferentAmount:
		return "TransferPendingTransferHasDifferentAmount"
	case TransferPendingTransferAlreadyPosted:
		return "TransferPendingTransferAlreadyPosted"
	case TransferPendingTransferAlreadyVoided:
		return "TransferPendingTransferAlreadyVoided"
	case TransferPendingTransferExpired:
		return "TransferPendingTransferExpired"
	}
	return "CreateTransferResult(" + strconv.FormatInt(int64(i+1), 10) + ")"
}

type AccountEventResult struct {
	Index  uint32
	Result CreateAccountResult
}

type TransferEventResult struct {
	Index  uint32
	Result CreateTransferResult
}

