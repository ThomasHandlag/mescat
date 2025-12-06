// @dart=3.0
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_local_variable, unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
  '[{"inputs":[{"internalType":"string","name":"eid","type":"string"}],"name":"getSSSS","outputs":[{"internalType":"string","name":"","type":"string"},{"internalType":"string","name":"","type":"string"},{"internalType":"bool","name":"","type":"bool"},{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"string","name":"eid","type":"string"},{"internalType":"string","name":"content","type":"string"},{"internalType":"bool","name":"hasCid","type":"bool"},{"internalType":"string","name":"cid","type":"string"}],"name":"setSSSS","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
  'Mescat',
);

class Mescat extends _i1.GeneratedContract {
  Mescat({
    required _i1.EthereumAddress address,
    required _i1.Web3Client client,
    int? chainId,
  }) : super(
          _i1.DeployedContract(
            _contractAbi,
            address,
          ),
          client,
          chainId,
        );

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetSSSS> getSSSS(
    ({String eid}) args, {
    _i1.BlockNum? atBlock,
  }) async {
    final function = self.abi.functions[0];
    assert(checkSignature(function, 'eadc71c5'));
    final params = [args.eid];
    final response = await read(
      function,
      params,
      atBlock,
    );
    return GetSSSS(response);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> setSSSS(
    ({String eid, String content, bool hasCid, String cid}) args, {
    required _i1.Credentials credentials,
    _i1.Transaction? transaction,
  }) async {
    final function = self.abi.functions[1];
    assert(checkSignature(function, '148f6733'));
    final params = [
      args.eid,
      args.content,
      args.hasCid,
      args.cid,
    ];
    return write(
      credentials,
      transaction,
      function,
      params,
    );
  }
}

class GetSSSS {
  GetSSSS(List<dynamic> response)
      : var1 = (response[0] as String),
        var2 = (response[1] as String),
        var3 = (response[2] as bool),
        var4 = (response[3] as String);

  final String var1;

  final String var2;

  final bool var3;

  final String var4;
}
