class Lancamentos{
  int ordemlancamento; // numero de ordem de lancamento
  int ordemcontabil; // numero para ordenacao dos relatorios contabeis
  DateTime datalancamento; // data do lancamento
  String contadebito; // numero da conta debitada
  String contadebitoreduzida; // numero reduzido da conta debitada
  String nomecontadebito; // nome da conta debitada
  String contacredito; // numero da conta creditada
  String contacreditoreduzida; // numero reduzido da conta creditada
  String nomecontacredito; // nome da conta creditada
  String valorlancamento; // valor do lancamento
  String historicolancamento; // historico/referencia do lancamento

  Lancamentos(
      this.ordemlancamento,
      this.ordemcontabil,
      this.datalancamento,
      this.contadebito,
      this.contadebitoreduzida,
      this.nomecontadebito,
      this.contacredito,
      this.contacreditoreduzida,
      this.nomecontacredito,
      this.valorlancamento,
      this.historicolancamento
      );
}