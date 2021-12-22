import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import '../objetos/Lancamentos.dart';
import '../objetos/Conta.dart';



class LancamentosContabeis extends StatefulWidget {
  //const LancamentosContabeis({Key? key}) : super(key: key);

  List<Conta> contasContabeis;

  LancamentosContabeis(this.contasContabeis);

  @override
  _LancamentosContabeisState createState() => _LancamentosContabeisState();
}

class _LancamentosContabeisState extends State<LancamentosContabeis> {

  FirebaseFirestore basededadosfirestore = FirebaseFirestore.instance;

  DateTime? dataLancamento;

  TextEditingController valorController = TextEditingController();
  String? valor;

  TextEditingController debitoController = TextEditingController();
  String? debito;

  TextEditingController creditoController = TextEditingController();
  String? credito;

  TextEditingController historicoController = TextEditingController();
  String? historico;

  String descricaoDebito = "";
  String descricaoCredito = "";
  String numeroContaDebito = "";
  String numeroContaCredito = "";

  String msg = "";

  bool enviandoLancamento = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lançamentos Contábeis"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container(),),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: TextButton(
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
                                dataLancamento = date;
                              });
                            },
                            currentTime: DateTime(2021, 1, 1),
                            locale: LocaleType.pt
                        );
                      },
                      child: Text(
                        dataLancamento != null ? formatarData(dataLancamento.toString()) : "Data Lançamento",
                        style: const TextStyle(color: Colors.white),
                      )),
                ),
              ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                        labelText: "Valor",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [CurrencyTextInputFormatter(turnOffGrouping: true,symbol: "")],
                    style: const TextStyle(color: Colors.blue),
                    controller: valorController,
                    onChanged: (v){
                      setState(() {
                        valor = v;
                      });
                    },
                  ),
                ),
              ),
              Expanded(child: Container(),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container(),),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Débito",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: credito == debito ? Colors.red : Colors.blue),
                    controller: debitoController,
                    onChanged: (v){
                      bool encontrado = false;
                      for(var conta in widget.contasContabeis){
                        if(conta.numeroreduzido == v){
                          encontrado = true;
                          setState(() {
                            numeroContaDebito = conta.numeroconta;
                            descricaoDebito = conta.nomeconta;
                          });
                        }else if(encontrado == false){
                          setState(() {
                            numeroContaDebito = "";
                            descricaoDebito = "";
                          });
                        }
                      }
                      setState(() {
                        debito = v;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 50,
                  child: Text(
                      numeroContaDebito == "" ? "Informe uma conta" : "$numeroContaDebito $descricaoDebito"
                  ),
                ),
              ),
              Expanded(child: Container(),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container(),),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Crédito",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: credito == debito ? Colors.red : Colors.blue),
                    controller: creditoController,
                    onChanged: (v){
                      bool encontrado = false;
                      for(var conta in widget.contasContabeis){
                        if(conta.numeroreduzido == v){
                          encontrado = true;
                          setState(() {
                            numeroContaCredito = conta.numeroconta;
                            descricaoCredito = conta.nomeconta;
                          });
                        }else if(encontrado == false){
                          setState(() {
                            numeroContaCredito = "";
                            descricaoCredito = "";
                          });
                        }
                      }
                      setState(() {
                        credito = v;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 50,
                  child: Text(
                      numeroContaCredito == "" ? "Informe uma conta" : "$numeroContaCredito $descricaoCredito"
                  ),
                ),
              ),
              Expanded(child: Container(),),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container(),),
              Expanded(
                flex: 6,
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 50,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: "Histórico do Lançamento",
                    ),
                    style: const TextStyle(color: Colors.blue),
                    controller: historicoController,
                    onChanged: (v){
                      setState(() {
                        historico = v;
                      });
                    },
                  ),
                ),
              ),
              Expanded(child: Container(),),
            ],
          ),
          const SizedBox(height: 10),
          Text(msg, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center,),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Container(),),
              Expanded(flex: 1,child: Container(color: Colors.blue, child: const Text("ID", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),),),
              Expanded(flex: 1,child: Container(color: Colors.blue, child: const Text("Número", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),),),
              Expanded(flex: 2,child: Container(color: Colors.blue, child: const Text("Data", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),),),
              Expanded(flex: 2,child: Container(color: Colors.blue, child: const Text("Valor", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),),),
              Expanded(flex: 3,child: Container(color: Colors.blue, child: const Text("Débito", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),),),
              Expanded(flex: 3,child: Container(color: Colors.blue, child: const Text("Crédito", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),),),
              Expanded(flex: 4,child: Container(color: Colors.blue, child: const Text("Histórico", style: TextStyle(color: Colors.white), textAlign: TextAlign.center),),),
              Expanded(child: Container(),),
            ],
          ),
          Expanded(
              child: StreamBuilder(
                stream: basededadosfirestore.collection("lancamentoscontabeis").orderBy("ordemlancamento").snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
                  if(streamSnapshot.hasData){
                    return ListView.builder(
                      itemCount: streamSnapshot.data!.docs.length,
                      itemBuilder: (context, index){
                        final DocumentSnapshot documento = streamSnapshot.data!.docs[index];
                        return Material(
                          child: Row(
                            children: [
                              Expanded(child: Container(),),
                              Expanded(flex: 1,child: Text("${documento["ordemlancamento"]}", textAlign: TextAlign.center),),
                              Expanded(flex: 1,child: Text("${documento["ordemcontabil"]}", textAlign: TextAlign.center),),
                              Expanded(flex: 2,child: Text("${formatarData(documento["datalancamento"].toDate().toString())}", textAlign: TextAlign.center),),
                              Expanded(flex: 2,child: Text("${documento["valorlancamento"]}", textAlign: TextAlign.center),),
                              Expanded(flex: 3,child: Text("${documento["contadebito"]} ${documento["nomecontadebito"]}"),),
                              Expanded(flex: 3,child: Text("${documento["contacredito"]} ${documento["nomecontacredito"]}"),),
                              Expanded(flex: 4,child: Text("${documento["historicolancamento"]}"),),
                              Expanded(child: Container(),),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator(),);
                },
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: enviandoLancamento == true? null : () async {

          setState(() {
            msg = "";
            enviandoLancamento = true;
          });

          if(dataLancamento == null){
            setState(() {
              msg = "Informe a data do lançamento!";
              enviandoLancamento = false;
            });
          }else{
            if(valor == null || valor == ""){
              setState(() {
                msg = "Informe o valor do lançamento!";
                enviandoLancamento = false;
              });
            }else{
              if(debito == null || debito == ""){
                setState(() {
                  msg = "Informe a conta débito do lançamento!";
                  enviandoLancamento = false;
                });
              }else{
                if(credito == null || credito == ""){
                  setState(() {
                    msg = "Informe a conta crédito do lançamento!";
                    enviandoLancamento = false;
                  });
                }else{
                  if(debito == credito){
                    setState(() {
                      msg = "As contas de débito e crédito não podem ser iguais!";
                      enviandoLancamento = false;
                    });
                  }else{
                    if(historico == null || historico == ""){
                      setState(() {
                        msg = "Informe o histórico do lançamento!";
                        enviandoLancamento = false;
                      });
                    }else{

                      var contasfirebase = await basededadosfirestore.collection("contador").doc("numerolancamentos").get();
                      int numerolancamento = contasfirebase["quantidade"] + 1;

                      basededadosfirestore.collection("lancamentoscontabeis").doc("$numerolancamento").set(
                          {
                            "ordemlancamento" : numerolancamento,
                            "ordemcontabil" : 0,
                            "datalancamento" : dataLancamento,
                            "contadebito" : numeroContaDebito,
                            "contadebitoreduzida" : debito,
                            "nomecontadebito" : descricaoDebito,
                            "contacredito" : numeroContaCredito,
                            "contacreditoreduzida" : credito,
                            "nomecontacredito" : descricaoCredito,
                            "valorlancamento" : valor,
                            "historicolancamento" : historico,
                          }
                      ).catchError((erro){setState(() { msg = erro; });}).whenComplete(
                              () async {

                            basededadosfirestore.collection("contador").doc("numerolancamentos").update(
                                {
                                  "quantidade": numerolancamento
                                }
                            );

                            List<Lancamentos> lancamentos = [];

                            var lancamentosfirebase = await basededadosfirestore.collection("lancamentoscontabeis").get();

                            for(DocumentSnapshot lancamento in lancamentosfirebase.docs){
                              lancamentos.add(
                                  Lancamentos(
                                      lancamento["ordemlancamento"],
                                      0,
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

                            lancamentos.sort((a, b) => a.datalancamento.toString().compareTo(b.datalancamento.toString()));

                            int variavelDeOrdenacao = 1;

                            for(var lancamento in lancamentos){
                              lancamento.ordemcontabil = variavelDeOrdenacao++;
                            }

                            for(var lancamento in lancamentos){
                              basededadosfirestore.collection("lancamentoscontabeis").doc("${lancamento.ordemlancamento}").update(
                                  {
                                    "ordemcontabil": lancamento.ordemcontabil
                                  }
                              );
                            }

                            setState(() {
                              dataLancamento = null;
                              numeroContaDebito = "";
                              debito = null;
                              descricaoDebito = "";
                              numeroContaCredito = "";
                              credito = null;
                              descricaoCredito = "";
                              valor = null;
                              historico = null;
                              valorController.clear();
                              debitoController.clear();
                              creditoController.clear();
                              historicoController.clear();
                              enviandoLancamento = false;
                            });


                          }
                      );

                    }
                  }
                }
              }
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  formatarData(String data){
    return DateFormat("dd/MM/yyyy").format(DateTime.parse(data));
  }

}
