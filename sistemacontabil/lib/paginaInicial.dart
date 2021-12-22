import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../lancamentosContabeis.dart';
import '../planoDeContas.dart';
import '../relatoriosContabeis.dart';
import '../objetos/Conta.dart';

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({Key? key}) : super(key: key);

  @override
  _PaginaInicialState createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contabil"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 1,
        width: MediaQuery.of(context).size.width * 1,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedContainer(height: 150, width: 150,duration: const Duration(seconds: 1), child: InkWell(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> const PlanoDeContas()));}, child: Column(mainAxisAlignment: MainAxisAlignment.center,children: const [Icon(Icons.list), Text("Plano de Contas")],),),),
              AnimatedContainer(
                height: 150,
                width: 150,
                duration: const Duration(seconds: 1),
                child: InkWell(
                  onTap: () async {

                    List<Conta> contascontabeisfirebase = [];

                    var contasfirebase = await FirebaseFirestore.instance.collection("planodecontas").get();

                    for(DocumentSnapshot conta in contasfirebase.docs){
                      if(conta["tipodeconta"] == "analitica"){
                        contascontabeisfirebase.add(
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
                              conta["conta"]
                            )
                        );
                      }
                    }

                    Navigator.push(
                        context, MaterialPageRoute(builder: (context)=> LancamentosContabeis(contascontabeisfirebase))
                    );
                    },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.edit), Text("Lançamentos")],
                  ),
                ),
              ),
              AnimatedContainer(height: 150, width: 150,duration: const Duration(seconds: 1), child: InkWell(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> const RelatoriosContabeis()));}, child: Column(mainAxisAlignment: MainAxisAlignment.center,children: const [Icon(Icons.folder_open), Text("Relatórios")],),),),
            ],
          ),
        ),
      ),
    );
  }
}
