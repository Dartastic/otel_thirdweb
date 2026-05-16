// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_thirdweb/otel_thirdweb.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_thirdweb-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('account.execute records smart account + gasless + UserOp', () async {
    await tracedThirdweb<String>(
      operation: 'account.execute',
      invoke: () async => const ThirdwebCallResult(
        value: 'ok',
        result: ThirdwebResult(
          clientId: 'cli_1',
          chainId: 8453,
          chainSlug: 'base',
          contractKind: 'Account',
          walletKind: 'SmartWallet',
          smartAccountAddress: '0xsa',
          gasless: true,
          userOpHash: '0xuop',
          paymasterPolicyId: 'pp_1',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('thirdweb account.execute')!);
    expect(a['thirdweb.gasless'], true);
    expect(a['thirdweb.smart_account.address'], '0xsa');
    expect(a['thirdweb.chain.slug'], 'base');
  });

  test('errored tx status sets span error', () async {
    await tracedThirdweb<String>(
      operation: 'sendTransaction',
      invoke: () async => const ThirdwebCallResult(
        value: 'ok',
        result: ThirdwebResult(txStatus: 'errored', txHash: '0xabc'),
      ),
    );
    expect(
      spans.findSpanByName('thirdweb sendTransaction')!.status,
      SpanStatusCode.Error,
    );
  });

  test('confirmed tx is non-error', () async {
    await tracedThirdweb<String>(
      operation: 'waitForReceipt',
      invoke: () async => const ThirdwebCallResult(
        value: 'ok',
        result: ThirdwebResult(
          txStatus: 'confirmed',
          gasUsed: 78000,
        ),
      ),
    );
    expect(
      spans.findSpanByName('thirdweb waitForReceipt')!.status,
      isNot(SpanStatusCode.Error),
    );
  });

  test('suppression skips spans', () async {
    await runWithoutThirdwebInstrumentationAsync(() async {
      await tracedThirdweb<String>(
        operation: 'getContract',
        invoke: () async => const ThirdwebCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('thirdweb '), isEmpty);
  });
}
