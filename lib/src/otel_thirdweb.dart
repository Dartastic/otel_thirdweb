// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_thirdweb_suppression.dart';

const _tracerName = 'dartastic_otel_libs_thirdweb';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class ThirdwebResult {
  const ThirdwebResult({
    this.clientId,
    this.chainId,
    this.chainSlug,
    this.contractAddress,
    this.contractKind,
    this.method,
    this.walletKind,
    this.walletAddress,
    this.smartAccountAddress,
    this.gasless,
    this.sponsoredOpHash,
    this.userOpHash,
    this.txHash,
    this.txStatus,
    this.gasUsed,
    this.engineQueueId,
    this.paymasterPolicyId,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// thirdweb cloud project client id.
  final String? clientId;

  /// Numeric chain id (`1`, `137`, `42161`, `8453`, `10`).
  final int? chainId;

  /// `ethereum`, `polygon`, `arbitrum`, `base`, `optimism`,
  /// `bsc`, `avalanche`, `zora`, `mantle`, `sepolia`, `solana`.
  final String? chainSlug;

  final String? contractAddress;

  /// `Edition`, `Token`, `NFTCollection`, `NFTDrop`, `EditionDrop`,
  /// `TokenDrop`, `Marketplace`, `MarketplaceV3`, `Multiwrap`, `Pack`,
  /// `Split`, `Vote`, `AccountFactory`, `Account`.
  final String? contractKind;

  /// Contract method invoked.
  final String? method;

  /// `InAppWallet`, `EmbeddedWallet`, `SmartWallet`, `Coinbase`,
  /// `MetaMask`, `Rainbow`, `Trust`, `Zerion`, `WalletConnect`.
  final String? walletKind;

  final String? walletAddress;

  /// Smart-account 4337 wallet address (when paymaster sponsored).
  final String? smartAccountAddress;

  /// Gasless transaction (relayer / paymaster sponsored).
  final bool? gasless;

  /// 4337 UserOperation hash.
  final String? userOpHash;
  final String? sponsoredOpHash;

  /// On-chain transaction hash after inclusion.
  final String? txHash;

  /// `queued`, `submitted`, `mined`, `confirmed`, `errored`, `cancelled`,
  /// `replaced`.
  final String? txStatus;

  /// Gas used (`tx.gasUsed`).
  final int? gasUsed;

  /// thirdweb Engine queue id (server-side relayer).
  final String? engineQueueId;

  final String? paymasterPolicyId;

  final String? errorCode;
  final String? errorMessage;

  final int? statusCode;
}

class ThirdwebCallResult<T> {
  const ThirdwebCallResult({required this.value, this.result});
  final T value;
  final ThirdwebResult? result;
}

/// Wraps a thirdweb call in a CLIENT span. [operation] is one of
/// `read`, `prepareTransaction`, `sendTransaction`, `waitForReceipt`,
/// `simulateTransaction`, `getBalance`, `getContract`,
/// `wallet.connect`, `wallet.disconnect`, `wallet.signMessage`,
/// `wallet.signTypedData`, `wallet.switchChain`, `wallet.signAuthorization`,
/// `account.preAuthorize`, `account.deploy`, `account.execute`,
/// `engine.submit`, `engine.poll`, `engine.cancel`,
/// `pay.getBuyWithFiatQuote`, `pay.getBuyWithCryptoQuote`,
/// `pay.getStatus`, `storage.upload`, `storage.download`,
/// `analytics.fetch`, `auth.login`, `auth.verify`.
Future<T> tracedThirdweb<T>({
  required String operation,
  required Future<ThirdwebCallResult<T>> Function() invoke,
}) async {
  if (thirdwebInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'thirdweb',
    'rpc.method': operation,
    'thirdweb.operation': operation,
  };

  final span = _tracer().startSpan(
    'thirdweb $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.clientId != null) {
        extras.add(OTel.attributeString('thirdweb.client.id', res.clientId!));
      }
      if (res.chainId != null) {
        extras.add(OTel.attributeInt('thirdweb.chain.id', res.chainId!));
      }
      if (res.chainSlug != null) {
        extras.add(OTel.attributeString(
          'thirdweb.chain.slug',
          res.chainSlug!,
        ));
      }
      if (res.contractAddress != null) {
        extras.add(OTel.attributeString(
          'thirdweb.contract.address',
          res.contractAddress!,
        ));
      }
      if (res.contractKind != null) {
        extras.add(OTel.attributeString(
          'thirdweb.contract.kind',
          res.contractKind!,
        ));
      }
      if (res.method != null) {
        extras.add(OTel.attributeString('thirdweb.method', res.method!));
      }
      if (res.walletKind != null) {
        extras.add(OTel.attributeString(
          'thirdweb.wallet.kind',
          res.walletKind!,
        ));
      }
      if (res.walletAddress != null) {
        extras.add(OTel.attributeString(
          'thirdweb.wallet.address',
          res.walletAddress!,
        ));
      }
      if (res.smartAccountAddress != null) {
        extras.add(OTel.attributeString(
          'thirdweb.smart_account.address',
          res.smartAccountAddress!,
        ));
      }
      if (res.gasless != null) {
        extras.add(OTel.attributeBool('thirdweb.gasless', res.gasless!));
      }
      if (res.userOpHash != null) {
        extras.add(OTel.attributeString(
          'thirdweb.user_op.hash',
          res.userOpHash!,
        ));
      }
      if (res.sponsoredOpHash != null) {
        extras.add(OTel.attributeString(
          'thirdweb.sponsored_op.hash',
          res.sponsoredOpHash!,
        ));
      }
      if (res.txHash != null) {
        extras.add(OTel.attributeString('thirdweb.tx.hash', res.txHash!));
      }
      if (res.txStatus != null) {
        extras.add(OTel.attributeString('thirdweb.tx.status', res.txStatus!));
        if (res.txStatus == 'errored') {
          span.setStatus(SpanStatusCode.Error, 'thirdweb tx errored');
        }
      }
      if (res.gasUsed != null) {
        extras.add(OTel.attributeInt('thirdweb.tx.gas_used', res.gasUsed!));
      }
      if (res.engineQueueId != null) {
        extras.add(OTel.attributeString(
          'thirdweb.engine.queue_id',
          res.engineQueueId!,
        ));
      }
      if (res.paymasterPolicyId != null) {
        extras.add(OTel.attributeString(
          'thirdweb.paymaster.policy_id',
          res.paymasterPolicyId!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'thirdweb.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'thirdweb ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'thirdweb.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'thirdweb HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
