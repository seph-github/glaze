import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:glaze/features/shop/services/payment_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_provider.freezed.dart';
part 'payment_provider.g.dart';

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState({
    @Default(false) bool isLoading,
    @Default(null) dynamic error,
  }) = _PaymentState;

  const PaymentState._();
}

@riverpod
class PaymentNotifier extends _$PaymentNotifier {
  @override
  PaymentState build() {
    return const PaymentState();
  }

  setError(dynamic e) {
    state = state.copyWith(error: null);
    state = state.copyWith(error: e, isLoading: false);
  }

  Future<void> makePayment(String amount) async {
    state = state.copyWith(error: null, isLoading: true);
    try {
      await PaymentServices.makePayment(amount);
      state = state.copyWith(error: null, isLoading: false);
    } catch (e) {
      setError(e);
    }
  }
}
