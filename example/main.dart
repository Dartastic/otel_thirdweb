// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_thirdweb/otel_thirdweb.dart';

/// Traces thirdweb calls with OpenTelemetry.
///
/// `otel_thirdweb` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each thirdweb call in
/// [tracedThirdweb]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'thirdweb-example');

  // Wraps a thirdweb call in a CLIENT span.
  final thirdwebId = await tracedThirdweb<String>(
    operation: 'wallet.connect',
    invoke: () async {
      // Make the thirdweb call here, then report what it returned.
      const id = 'thirdweb_8f3a2c';
      return const ThirdwebCallResult(
          value: id,
          result: ThirdwebResult(
              clientId: 'client_8f3a2c',
              chainId: 1,
              chainSlug: 'ethereum',
              contractAddress: 'example',
              contractKind: 'Edition',
              method: 'POST',
              walletKind: 'InAppWallet',
              walletAddress: 'example',
              smartAccountAddress: 'example',
              gasless: true,
              sponsoredOpHash: 'example',
              userOpHash: 'example',
              txHash: 'example',
              txStatus: 'queued',
              gasUsed: 1,
              engineQueueId: 'enginequeue_8f3a2c',
              paymasterPolicyId: 'paymasterpolicy_8f3a2c',
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedThirdweb wallet.connect returned $thirdwebId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutThirdwebInstrumentationAsync.
  await runWithoutThirdwebInstrumentationAsync(
    () => tracedThirdweb<String>(
      operation: 'wallet.connect',
      invoke: () async {
        const id = 'thirdweb_8f3a2c';
        return const ThirdwebCallResult(
            value: id,
            result: ThirdwebResult(
                clientId: 'client_8f3a2c',
                chainId: 1,
                chainSlug: 'ethereum',
                contractAddress: 'example',
                contractKind: 'Edition',
                method: 'POST',
                walletKind: 'InAppWallet',
                walletAddress: 'example',
                smartAccountAddress: 'example',
                gasless: true,
                sponsoredOpHash: 'example',
                userOpHash: 'example',
                txHash: 'example',
                txStatus: 'queued',
                gasUsed: 1,
                engineQueueId: 'enginequeue_8f3a2c',
                paymasterPolicyId: 'paymasterpolicy_8f3a2c',
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
