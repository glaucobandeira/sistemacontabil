import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import '../objetos/Conta.dart';
import '../objetos/Lancamentos.dart';

class RelatoriosContabeis extends StatefulWidget {
  const RelatoriosContabeis({Key? key}) : super(key: key);

  @override
  _RelatoriosContabeisState createState() => _RelatoriosContabeisState();
}

class _RelatoriosContabeisState extends State<RelatoriosContabeis> {

  FirebaseFirestore basededadosfirestore = FirebaseFirestore.instance;

  List<Conta> relatorio = [];

  DateTime dataInicial = DateTime(2021, 1, 1);
  DateTime dataFinal = DateTime(2021, 12, 31);
  bool encerrarPeriodo = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatórios Contábeis"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        width: MediaQuery.of(context).size.width * 1,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blue
                      ),
                      onPressed: () {
                        DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(2021, 1, 1),
                            maxTime: DateTime(2021, 12, 31),
                            onConfirm: (date) {
                              setState(() {
                                dataInicial = date;
                              });
                            },
                            currentTime: DateTime(2021, 1, 1),
                            locale: LocaleType.pt
                        );
                      },
                      child: Text(
                        formatarData(dataInicial.toString()),
                        style: const TextStyle(color: Colors.white),
                      )
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blue
                      ),
                      onPressed: () {
                        DatePicker.showDatePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime(2021, 1, 1),
                            maxTime: DateTime(2021, 12, 31),
                            onConfirm: (date) {
                              setState(() {
                                dataFinal = date;
                              });
                            },
                            currentTime: DateTime(2021, 1, 1),
                            locale: LocaleType.pt
                        );
                      },
                      child: Text(
                        formatarData(dataFinal.toString()),
                        style: const TextStyle(color: Colors.white),
                      )
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: encerrarPeriodo ? Colors.green : Colors.deepOrangeAccent
                      ),
                      onPressed: () {
                        setState(() {
                          encerrarPeriodo = !encerrarPeriodo;
                        });
                      },
                      child: Text(
                        encerrarPeriodo ? "Período Encerrado" : "Período Aberto",
                        style: const TextStyle(color: Colors.white),
                      )
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedContainer(
                    height: 150,
                    width: 150,
                    duration: const Duration(seconds: 1),
                    child: InkWell(
                      onTap: () async {
                        gerarDados(tipoDados: "patrimonial");
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.article),
                          Text("BP")
                        ]
                        ,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    height: 150,
                    width: 150,
                    duration: const Duration(seconds: 1),
                    child: InkWell(
                      onTap: () async {
                        gerarDados(tipoDados: "resultado");
                      },
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,children: const [Icon(Icons.article), Text("DRE")],
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    height: 150,
                    width: 150,
                    duration: const Duration(seconds: 1),
                    child: InkWell(
                      onTap: () async {
                        gerarDados();
                      },
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,children: const [Icon(Icons.article), Text("BC")],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Material(
                  child: ListView.builder(
                      itemCount: relatorio.length,
                      itemBuilder: (context, index){

                        Conta item = relatorio[index];
                        Color? cor = Colors.transparent;
                        bool valorNegativo = false;

                        // aplicando cores para as contas sintéticas em seus respectivos níveis
                        if(item.numeroconta.substring(2,17) == "00.00.000.00000"){
                          cor = Colors.grey[600];
                        }else if(item.numeroconta.substring(5,17) == "00.000.00000"){
                          cor = Colors.grey[500];
                        }else if(item.numeroconta.substring(8,17) == "000.00000"){
                          cor = Colors.grey[400];
                        }else if(item.numeroconta.substring(12,17) == "00000"){
                          cor = Colors.grey[300];
                        }

                        // verificando se o valor da conta é negativo
                        // *** lembrando que o conceito de valor negativo é
                        // variável conforme a natureza da conta ***
                        if(item.valor.toString().indexOf("-") == 0){
                          valorNegativo = true;
                        }

                        final formatoMoeda = NumberFormat.currency(locale: "pt_BR", symbol: "");

                        return Container(
                          color: cor,
                          child: Row(
                            children: [
                              Expanded(flex: 1,child: Container(),),
                              Expanded(flex: 2,child: Text(item.numeroconta),),
                              Expanded(flex: 5,child: Text(item.nomeconta, textAlign: TextAlign.left,),),
                              Expanded(flex: 1,child: Text(formatoMoeda.format(item.valor).toString().replaceAll("-", ""), textAlign: TextAlign.right,),),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                // nos relatórios contábeis não demonstramos a conta
                                // negativa utilizando o sinal de menos, mas sim com
                                // C (de Crédito ou Credora) e D (de Devedora ou Débito)
                                // *** lembrando que contas de Natureza Devedora negativas
                                // são representadas por C.
                                // E contas de Natureza Credora negativas são representadas
                                // por D.
                                // Por sua vez, as contas que ficaram positivas, são representadas
                                // respectivamente pelas iniciais de suas naturezas (C para contas de
                                // natureza Credora, e D para contas de natureza Devedora)
                                child: item.natureza == "Devedora" ? Text(valorNegativo == true ? "C" : "D") : Text(valorNegativo == true ? "D" : "C"),
                              ),
                              Expanded(flex: 3,child: Container(),),
                            ],
                          ),
                        );
                      }
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  gerarDados({String tipoDados = ""}) async {

    // criei uma lista para armazenar os lancamentos
    List<Lancamentos> lancamentos = [];
    // busquei os lancamentos na base de dados e armazenei em uma variável
    var lancamentosfirebase = await basededadosfirestore.collection("lancamentoscontabeis").get();
    // inseri esses dados dentro da lista criada anteriormente
    // com base na data inicial e final dos lançamentos
    for(DocumentSnapshot lancamento in lancamentosfirebase.docs){
      if(dataInicial.compareTo(lancamento["datalancamento"].toDate()) <= 0  &&
          dataFinal.compareTo(lancamento["datalancamento"].toDate()) >= 0){
        lancamentos.add(
            Lancamentos(
                lancamento["ordemlancamento"],
                lancamento["ordemcontabil"],
                lancamento["datalancamento"].toDate(),
                lancamento["contadebito"],
                lancamento["contadebitoreduzida"],
                lancamento["nomecontadebito"],
                lancamento["contacredito"],
                lancamento["contacreditoreduzida"],
                lancamento["nomecontacredito"],
                lancamento["valorlancamento"],
                lancamento["historicolancamento"]
            )
        );
      }
    }
    // ordenei os lançamentos pela ordem contábil
    // *** vale ressaltar a seguinte questão: "nao poderíamos ter ordenado por data?"
    // nessa situação sim, mas como já temos o numero de ordenacao contábil que será
    // usado para outros tipos de relatórios, podemos aproveitar esses dados que reflete
    // a ordenação por data ***
    lancamentos.sort((a, b) => a.ordemcontabil.compareTo(b.ordemcontabil));

    // criei uma lista para armazenar as conta contábeis que serão utilizadas nos relatórios
    // tais como: Balanco Patrimonial (BP), Demonstracao do Resultado do Exercicio (DRE) e
    // Balancete Contabil (BC)
    List<Conta> contascontabeis = [];
    // busquei todas as contas na base de dados e armazenei em uma variável
    var contasfirebase = await FirebaseFirestore.instance.collection("planodecontas").get();
    for(DocumentSnapshot conta in contasfirebase.docs){
      // inseri esses dados dentro da lista criada para as contas contabeis
      contascontabeis.add(
          Conta(
              conta["numeroconta"],
              conta["numeroreduzido"],
              conta["nomeconta"],
              conta["nivel1"],
              conta["nivel2"],
              conta["nivel3"],
              conta["nivel4"],
              conta["nivel5"],
              conta["natureza"],
              conta["localizacao"],
              conta["tipodeconta"],
              conta["conta"],
              valor: 0
          )
      );
    }

    // aqui ordeno essa lista a partir da sua numeracao,
    // como ex.: 1.00.00.000.00000, 1.01.00.000.00000, 1.01.01.000.00000 e por aí vai
    contascontabeis.sort((a, b) => a.numeroconta.compareTo(b.numeroconta));

    // aqui eu junto as informacoes da lista de lancamentos dentro
    // da lista de contas contabeis
    // *** lembrando que aqui as contas a serem somadas sao analiticas,
    // uma vez que fazemos lancamentos apenas com elas ***
    for(var inserirLancamento in lancamentos){
      for(var contaInserida in contascontabeis){
        // verifico as contas que foram debitadas
        if(inserirLancamento.contadebito == contaInserida.numeroconta){
          // se elas são de natureza devedora
          if(contaInserida.natureza == "Devedora"){
            // serão somadas na lista de contas contabeis
            contaInserida.valor = contaInserida.valor + double.parse(inserirLancamento.valorlancamento);
          }else{
            // caso contrário (ou seja, são de natureza credora), serão subtraídas
            contaInserida.valor = contaInserida.valor - double.parse(inserirLancamento.valorlancamento);
          }
        }
        // verifico as contas que foram creditadas
        if(inserirLancamento.contacredito == contaInserida.numeroconta){
          // se elas são de natureza devedora
          if(contaInserida.natureza == "Devedora"){
            // serão subtraídas na lista de contas contabeis
            contaInserida.valor = contaInserida.valor - double.parse(inserirLancamento.valorlancamento);
          }else{
            // caso contrário (ou seja, são de natureza credora), serão somadas
            contaInserida.valor = contaInserida.valor + double.parse(inserirLancamento.valorlancamento);
          }
        }
      }
    }

    // aqui trataremos a lista das contas contabeis para inserir valor
    // nas contas sinteticas (que representam contas totalizadoras das suas
    // respectivas contas analiticas)
    for(var conta in contascontabeis){
      // verifico se a conta que quero somar é sintetica, se sim, passo a condicao abaixo
      if(conta.numeroconta.substring(12,17) != "00000"){
        for(var contasomada in contascontabeis){
          // se possuir os 4 primeiros níveis iguais, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && conta.nivel2 == contasomada.nivel2 &&
              conta.nivel3 == contasomada.nivel3 && conta.nivel4 == contasomada.nivel4 && "00000" == contasomada.nivel5){
            // se forem contas da mesma natureza, serão somadas
            if(conta.natureza == contasomada.natureza){
              contasomada.valor = contasomada.valor + conta.valor;
            }
            // se forem contas de natureza diferentes, serão subtraídas
            else{
              contasomada.valor = contasomada.valor - conta.valor;
            }
          }
          // se possuir os 3 primeiros níveis iguais, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && conta.nivel2 == contasomada.nivel2 &&
              conta.nivel3 == contasomada.nivel3 && "000" == contasomada.nivel4 && "00000" == contasomada.nivel5){
            // se forem contas da mesma natureza, serão somadas
            if(conta.natureza == contasomada.natureza){
              contasomada.valor = contasomada.valor + conta.valor;
            }
            // se forem contas de natureza diferentes, serão subtraídas
            else{
              contasomada.valor = contasomada.valor - conta.valor;
            }
          }
          // se possuir os 2 primeiros níveis iguais, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && conta.nivel2 == contasomada.nivel2 &&
              "00" == contasomada.nivel3 && "000" == contasomada.nivel4 && "00000" == contasomada.nivel5){
            // se forem contas da mesma natureza, serão somadas
            if(conta.natureza == contasomada.natureza){
              contasomada.valor = contasomada.valor + conta.valor;
            }
            // se forem contas de natureza diferentes, serão subtraídas
            else{
              contasomada.valor = contasomada.valor - conta.valor;
            }
          }
          // se possuir o primeiro nível igual, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && "00" == contasomada.nivel2 &&
              "00" == contasomada.nivel3 && "000" == contasomada.nivel4 && "00000" == contasomada.nivel5){
            // se forem contas da mesma natureza, serão somadas
            if(conta.natureza == contasomada.natureza){
              contasomada.valor = contasomada.valor + conta.valor;
            }
            // se forem contas de natureza diferentes, serão subtraídas
            else{
              contasomada.valor = contasomada.valor - conta.valor;
            }
          }
        }
      }
    }

    // lancamento de encerramento automatico sem inserir na base de dados,
    // mas mostrando nos relatorios
    if(encerrarPeriodo == true){
      double contaTransitoria = 0;
      double contaReceita = 0;
      double contaCusto = 0;
      double contaDespesa = 0;
      for(var conta in contascontabeis){
        if(conta.numeroconta == "3.00.00.000.00000"){
          contaReceita = conta.valor;
          for(var conta in contascontabeis){
            if(conta.numeroconta == "4.00.00.000.00000"){
              contaCusto = conta.valor;
              for(var conta in contascontabeis){
                contaDespesa = conta.valor;
                if(conta.numeroconta == "5.00.00.000.00000"){
                  contaTransitoria = contaReceita - contaCusto - contaDespesa;
                }
              }
            }
          }
        }
      }
      for(var conta in contascontabeis){
        if(contaTransitoria > 0){
          if(conta.numeroconta == "8.00.00.000.00000" ||
              conta.numeroconta == "8.01.00.000.00000" ||
              conta.numeroconta == "8.01.01.000.00000" ||
              conta.numeroconta == "8.01.01.001.00000"){
            setState(() {
              conta.valor = 0;
            });
          }
          if(conta.numeroconta == "8.01.01.001.00001"){
            setState(() {
              conta.valor = contaTransitoria;
            });
          }
          if(conta.numeroconta == "8.01.01.001.00003"){
            setState(() {
              conta.valor = contaTransitoria;
            });
          }
          if(conta.numeroconta == "2.03.01.003.00001"){
            setState(() {
              conta.valor = contaTransitoria;
            });
          }
          if(conta.numeroconta == "2.03.01.003.00000" ||
              conta.numeroconta == "2.03.01.000.00000" ||
              conta.numeroconta == "2.03.00.000.00000" ||
              conta.numeroconta == "2.00.00.000.00000"){
            setState(() {
              conta.valor = conta.valor + contaTransitoria;
            });
          }
        }else{
          if(conta.numeroconta == "8.00.00.000.00000" ||
              conta.numeroconta == "8.01.00.000.00000" ||
              conta.numeroconta == "8.01.01.000.00000" ||
              conta.numeroconta == "8.01.01.001.00000"){
            setState(() {
              conta.valor = -0;
            });
          }
          if(conta.numeroconta == "8.01.01.001.00002"){
            setState(() {
              conta.valor = -contaTransitoria;
            });
          }
          if(conta.numeroconta == "8.01.01.001.00003"){
            setState(() {
              conta.valor = contaTransitoria;
            });
          }
          if(conta.numeroconta == "2.03.01.003.00002"){
            setState(() {
              conta.valor = -contaTransitoria;
            });
          }
          if(conta.numeroconta == "2.03.01.003.00000" ||
              conta.numeroconta == "2.03.01.000.00000" ||
              conta.numeroconta == "2.03.00.000.00000" ||
              conta.numeroconta == "2.00.00.000.00000"){
            setState(() {
              conta.valor = conta.valor + contaTransitoria;
            });
          }
        }
      }
    }

    List<Conta> contasrelatorio = [];

    for(var conta in contascontabeis){
      // verifico se a conta que quero somar é sintetica, se sim, passo a condicao abaixo
      if(conta.numeroconta.substring(12,17) != "00000" && conta.valor != 0){
        conta.inserirNoRelatorio = true;
        for(var contasomada in contascontabeis){
          // se possuir os 3 primeiros níveis iguais, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && conta.nivel2 == contasomada.nivel2 &&
              conta.nivel3 == contasomada.nivel3 && conta.nivel4 == contasomada.nivel4 && "00000" == contasomada.nivel5){
            contasomada.inserirNoRelatorio = true;
          }
          // se possuir os 3 primeiros níveis iguais, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && conta.nivel2 == contasomada.nivel2 &&
              conta.nivel3 == contasomada.nivel3 && "000" == contasomada.nivel4 && "00000" == contasomada.nivel5){
            contasomada.inserirNoRelatorio = true;
          }
          // se possuir os 2 primeiros níveis iguais, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && conta.nivel2 == contasomada.nivel2 &&
              "00" == contasomada.nivel3 && "000" == contasomada.nivel4 && "00000" == contasomada.nivel5){
            contasomada.inserirNoRelatorio = true;
          }
          // se possuir o primeiro nível igual, eu operaciono a conta analitica a esse
          // grupo de conta sintetica
          if(conta.nivel1 == contasomada.nivel1 && "00" == contasomada.nivel2 &&
              "00" == contasomada.nivel3 && "000" == contasomada.nivel4 && "00000" == contasomada.nivel5){
            contasomada.inserirNoRelatorio = true;
          }
        }
      }
    }

    for(var conta in contascontabeis){
      // aqui utilizei a condiçao do parametro opcional, sendo que se não for passado,
      // ele pegará todos os dados para todas as contas, gerando o Balancete Contabil
      if(conta.inserirNoRelatorio == true && tipoDados == ""){
        contasrelatorio.add(conta);
      }
      // agora se caso tenha sido usado o parametro opcional, filtramos as contas a serem
      // usadas conforme o informado. Para o Balanco Patrimonial, é informado o tipo de conta "patrimonial"
      // e para a Demonstracao do Resultado do Exercicio, é informado o tipo de conta "resultado"
      else if(conta.inserirNoRelatorio == true && tipoDados != ""){
        if(conta.conta == tipoDados){
          contasrelatorio.add(conta);
        }
      }
    }

    // com todas as contas contabeis tratadas, eu adiciono a lista para
    // a lista do relatório, imprimindo-a na tela de consulta
    setState(() {
      relatorio = contasrelatorio;
    });
  }

  formatarData(String data){
    return DateFormat("dd/MM/yyyy").format(DateTime.parse(data));
  }
}