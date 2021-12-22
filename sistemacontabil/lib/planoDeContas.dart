import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../insercaoDeDados/contaContabil.dart';
import '../objetos/Conta.dart';

class PlanoDeContas extends StatefulWidget {
  const PlanoDeContas({Key? key}) : super(key: key);

  @override
  _PlanoDeContasState createState() => _PlanoDeContasState();
}

class _PlanoDeContasState extends State<PlanoDeContas> {

  FirebaseFirestore bancodedados = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plano de Contas"),
      ),
      body: StreamBuilder(
        stream: bancodedados.collection("planodecontas").orderBy("numeroconta").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
          if(streamSnapshot.hasData){
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index){
                final DocumentSnapshot documento = streamSnapshot.data!.docs[index];
                return Material(
                  child: ListTile(
                    title: Text("${documento["numeroconta"]} ${documento["nomeconta"]}"),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator(),);
        },
      ),
      floatingActionButton:
      FloatingActionButton.large(
        onPressed: () async {

          List<Conta> contascontabeisfirebase = [];

          var contasfirebase = await bancodedados.collection("planodecontas").get();

          for(DocumentSnapshot conta in contasfirebase.docs){
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
                  conta["conta"],
                  valor: 0
                )
            );
          }

          contascontabeisfirebase.sort((a, b) => a.numeroconta.compareTo(b.numeroconta));

          Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context)=> InserirContaContabil(contascontabeisfirebase)
          )
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


