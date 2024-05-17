type token = {paymentData: JSON.t}
type billingContact = {
  addressLines: array<string>,
  administrativeArea: string,
  countryCode: string,
  familyName: string,
  givenName: string,
  locality: string,
  postalCode: string,
}

type shippingContact = {
  emailAddress: string,
  phoneNumber: string,
  addressLines: array<string>,
  administrativeArea: string,
  countryCode: string,
  familyName: string,
  givenName: string,
  locality: string,
  postalCode: string,
}

type paymentResult = {token: JSON.t, billingContact: JSON.t, shippingContact: JSON.t}
type event = {validationURL: string, payment: paymentResult}
type innerSession
type session = {
  begin: unit => unit,
  abort: unit => unit,
  mutable oncancel: unit => unit,
  canMakePayments: unit => bool,
  mutable onvalidatemerchant: event => unit,
  completeMerchantValidation: JSON.t => unit,
  mutable onpaymentauthorized: event => unit,
  completePayment: JSON.t => unit,
  \"STATUS_SUCCESS": string,
  \"STATUS_FAILURE": string,
}
type applePaySession
type window = {\"ApplePaySession": applePaySession}

@val external window: window = "window"

@scope("window") @val external sessionForApplePay: Nullable.t<session> = "ApplePaySession"

@new external applePaySession: (int, JSON.t) => session = "ApplePaySession"

@deriving(abstract)
type total = {
  label: string,
  @optional \"type": string,
  amount: string,
}
type sdkNextAction = {nextAction: string}

@deriving(abstract)
type paymentRequestData = {
  countryCode: string,
  currencyCode: string,
  total: total,
  merchantCapabilities: array<string>,
  supportedNetworks: array<string>,
  @optional merchantIdentifier: string,
}

let jsonToPaymentRequestDataType: Dict.t<JSON.t> => paymentRequestData = jsonDict => {
  let clientTimeZone = CardUtils.dateTimeFormat().resolvedOptions().timeZone
  let clientCountry = Utils.getClientCountry(clientTimeZone)
  let defaultCountryCode = clientCountry.isoAlpha2

  let getTotal = totalDict => {
    Utils.getString(totalDict, "type", "") == ""
      ? total(
          ~label=Utils.getString(totalDict, "label", ""),
          ~amount=Utils.getString(totalDict, "amount", ""),
          (),
        )
      : total(
          ~label=Utils.getString(totalDict, "label", ""),
          ~amount=Utils.getString(totalDict, "amount", ""),
          ~\"type"=Utils.getString(totalDict, "type", ""),
          (),
        )
  }

  if Utils.getString(jsonDict, "merchant_identifier", "") == "" {
    paymentRequestData(
      ~countryCode=Utils.getString(jsonDict, "country_code", defaultCountryCode),
      ~currencyCode=Utils.getString(jsonDict, "currency_code", ""),
      ~merchantCapabilities=Utils.getStrArray(jsonDict, "merchant_capabilities"),
      ~supportedNetworks=Utils.getStrArray(jsonDict, "supported_networks"),
      ~total=getTotal(jsonDict->Utils.getDictFromObj("total")),
      (),
    )
  } else {
    paymentRequestData(
      ~countryCode=Utils.getString(jsonDict, "country_code", ""),
      ~currencyCode=Utils.getString(jsonDict, "currency_code", ""),
      ~merchantCapabilities=Utils.getStrArray(jsonDict, "merchant_capabilities"),
      ~supportedNetworks=Utils.getStrArray(jsonDict, "supported_networks"),
      ~total=getTotal(jsonDict->Utils.getDictFromObj("total")),
      ~merchantIdentifier=Utils.getString(jsonDict, "merchant_identifier", ""),
      (),
    )
  }
}

let billingContactItemToObjMapper = dict => {
  {
    addressLines: dict->Utils.getStrArray("addressLines"),
    administrativeArea: dict->Utils.getString("administrativeArea", ""),
    countryCode: dict->Utils.getString("countryCode", ""),
    familyName: dict->Utils.getString("familyName", ""),
    givenName: dict->Utils.getString("givenName", ""),
    locality: dict->Utils.getString("locality", ""),
    postalCode: dict->Utils.getString("postalCode", ""),
  }
}

let shippingContactItemToObjMapper = dict => {
  {
    emailAddress: dict->Utils.getString("emailAddress", ""),
    phoneNumber: dict->Utils.getString("phoneNumber", ""),
    addressLines: dict->Utils.getStrArray("addressLines"),
    administrativeArea: dict->Utils.getString("administrativeArea", ""),
    countryCode: dict->Utils.getString("countryCode", ""),
    familyName: dict->Utils.getString("familyName", ""),
    givenName: dict->Utils.getString("givenName", ""),
    locality: dict->Utils.getString("locality", ""),
    postalCode: dict->Utils.getString("postalCode", ""),
  }
}
