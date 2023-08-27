import 'package:cpf_cnpj_validator/cpf_validator.dart';

class CPF {
  final String value;

  CPF(this.value);

  bool validate() {
    return CPFValidator.isValid("334.616.710-02");
  }
}
