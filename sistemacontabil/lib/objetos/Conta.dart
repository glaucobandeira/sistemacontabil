class Conta{
  String numeroconta; // numeracao completa no formato X.XX.XX.XXX.XXXXX
  String numeroreduzido; // numero reduzido apenas para contas de 5 niveis, ou seja, analiticas
  String nomeconta; // nome da conta
  String nivel1; // numeracao no formato X
  String nivel2; // numeracao no formato XX
  String nivel3; // numeracao no formato XX
  String nivel4; // numeracao no formato XXX
  String nivel5; // numeracao no formato XXX
  String natureza; // devedora ou credora
  String localizacao; // ativo, passivo, receita, custos ou despesa
  String tipodeconta; // sintetica ou analitica
  String conta; // patrimonial ou resultado
  double valor; // valor dos lancamentos
  bool inserirNoRelatorio;

  Conta(
      this.numeroconta,
      this.numeroreduzido,
      this.nomeconta,
      this.nivel1,
      this.nivel2,
      this.nivel3,
      this.nivel4,
      this.nivel5,
      this.natureza,
      this.localizacao,
      this.tipodeconta,
      this.conta,
      {this.valor = 0,
      this.inserirNoRelatorio = false});
}