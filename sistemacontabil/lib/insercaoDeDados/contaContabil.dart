import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../objetos/Conta.dart';

class InserirContaContabil extends StatefulWidget {
  //const InserirContaContabil({Key? key}) : super(key: key);

  List<Conta> contasContabeis;

  InserirContaContabil(this.contasContabeis);

  @override
  _InserirContaContabilState createState() => _InserirContaContabilState();
}

class _InserirContaContabilState extends State<InserirContaContabil> {

  // instancia da base de dados
  FirebaseFirestore basededadosfirestore = FirebaseFirestore.instance;

  // listas que armazenarao dados buscados na base de dados
  List<String> nivelUm = [];
  List<String> nivelDois = [];
  List<String> nivelTres = [];
  List<String> nivelQuatro = [];

  // listas com dados fixos
  List<String> localizacao = ["Ativo","Passivo","Patrimônio Líquido","Receita","Custo","Despesa"];
  List<String> natureza = ["Credora","Devedora"];

  // variaveis que serao tratadas a partir dos dados inseridos nos campos de cadastro
  String? valorNivelUm;
  String? valorNivelDois;
  String? valorNivelTres;
  String? valorNivelQuatro;
  String? valorNivelCinco;
  String? valorLocalizacao;
  String? valorNatureza;

  // variaveis que receberao informacoes digitadas pelo usuario
  TextEditingController nomeContaController = TextEditingController();
  TextEditingController numeroReduzidaContaController = TextEditingController();
  String? nomeConta;
  String? numeroReduzidaConta;

  // variavel para armazenar msg de erro
  String msg = "";

  @override
  void initState() {
    // ao iniciar essa tela, buscamos contas sinteticas de primeiro nivel
    tratarContasEmNiveis();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inserir Conta Contábil"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            contaPatrimonial(nivelUm, "nivel1"),
            valorNivelUm == null ? Container() : nivelDois == [] ? Container() : contaPatrimonial(nivelDois, "nivel2"),
            valorNivelDois == null ? Container() : nivelTres == [] ? Container() : contaPatrimonial(nivelTres, "nivel3"),
            valorNivelTres == null ? Container() : nivelQuatro == [] ? Container() : contaPatrimonial(nivelQuatro, "nivel4"),
            valorNivelUm == null ? Container() : campoDeTexto("nome"), // nome da conta
            valorNivelQuatro == null ? Container() : campoDeTexto("numeroreduzido"), //numero reduzido
            valorNivelUm == null ? Container() : contaPatrimonial(localizacao, "localizacao"), // localizacao
            valorNivelUm == null ? Container() : contaPatrimonial(natureza, "natureza"), // natureza da conta
            Text(msg, style: const TextStyle(color: Colors.red),)
          ],
        ),
      ),
      floatingActionButton:
      FloatingActionButton.large(
        onPressed: () async {

          // crio variaveis dos niveis dentro da funcao
          String nivel1 = "0";
          String nivel2 = "00";
          String nivel3 = "00";
          String nivel4 = "000";
          String nivel5 = "00000";

          // reseto qualquer msg de erro que por ventura tenha dado anteriormente
          setState(() {
            msg = "";
          });

          // verifico se algum dos campos não foi preenchido
          if(valorNivelUm == null){
            // se o campo do nivel 1 nao foi informado, retorna essa msg de erro
            setState(() {
              msg = "Informe um nível de conta!";
            });
          }else{
            if(nomeConta == null || nomeConta == ""){
              // se o campo do nome da conta nao foi informado, retorna essa msg de erro
              setState(() {
                msg = "Preencha o nome da conta!";
              });
            }else{
              if(valorNivelQuatro != null && (numeroReduzidaConta == "" || numeroReduzidaConta == null)){
                // se o campo de codigo reduzido da conta nao foi informado, retorna essa msg de erro
                setState(() {
                  msg = "Preencha o código reduzido da conta!";
                });
              }else{
                // caso o cadastro tiver o preenchimento do nivel 4 (sintetico) para informar
                // conta de nivel 5 (analitico),
                // retornaremos seguinte codigo:
                if(valorNivelQuatro != null){
                  nivel1 = valorNivelDois.toString().substring(0,1);
                  nivel2 = valorNivelDois.toString().substring(2,4);
                  nivel3 = valorNivelTres.toString().substring(5,7);
                  nivel4 = valorNivelQuatro.toString().substring(8,11);
                  int contador = 1;
                  for(Conta conta in widget.contasContabeis){
                    if(conta.numeroconta.substring(0,11) == "$nivel1.$nivel2.$nivel3.$nivel4"
                        && conta.nivel5 != "00000") {
                      contador++;
                    }
                  }
                  int tamanhoNivel5 = contador.toString().length;
                  if(tamanhoNivel5 == 1){
                    nivel5 = "0000$contador";
                  }else if(tamanhoNivel5 == 2){
                    nivel5 = "000$contador";
                  }else if(tamanhoNivel5 == 3){
                    nivel5 = "00$contador";
                  }else if(tamanhoNivel5 == 4){
                    nivel5 = "0$contador";
                  }else{
                    nivel5 = "$contador";
                  }
                }

                // caso o cadastro tiver o preenchimento do nivel 3 (sintetico) para informar
                // conta de nivel 4 (sintetico),
                // retornaremos seguinte codigo:
                else if(valorNivelTres != null){
                  nivel1 = valorNivelDois.toString().substring(0,1);
                  nivel2 = valorNivelDois.toString().substring(2,4);
                  nivel3 = valorNivelTres.toString().substring(5,7);
                  int contador = 1;
                  for(Conta conta in widget.contasContabeis){
                    if(conta.numeroconta.substring(0,7) == "$nivel1.$nivel2.$nivel3"
                        && conta.nivel4 != "000") {
                      contador++;
                    }
                  }
                  int tamanhoNivel4 = contador.toString().length;
                  if(tamanhoNivel4 == 1){
                    nivel4 = "00$contador";
                  }else if(tamanhoNivel4 == 2){
                    nivel4 = "0$contador";
                  }else{
                    nivel4 = "$contador";
                  }
                }

                // caso o cadastro tiver o preenchimento do nivel 2 (sintetico) para informar
                // conta de nivel 3 (sintetico),
                // retornaremos o seguinte codigo:
                else if(valorNivelDois != null){
                  nivel1 = valorNivelDois.toString().substring(0,1);
                  nivel2 = valorNivelDois.toString().substring(2,4);
                  int contador = 1;
                  for(Conta conta in widget.contasContabeis){
                    if(conta.numeroconta.substring(0,4) == "$nivel1.$nivel2"
                        && conta.nivel3 != "00" && conta.nivel4 == "000") {
                      contador++;
                    }
                  }
                  int tamanhoNivel3 = contador.toString().length;
                  if(tamanhoNivel3 == 1){
                    nivel3 = "0$contador";
                  }else{
                    nivel3 = "$contador";
                  }
                }


                // caso o cadastro tiver o preenchimento apenas do nivel 1 (sintetico) para informar
                // conta de nivel 2 (sintetico),
                // retornaremos o seguinte codigo:
                else{
                  nivel1 = valorNivelUm.toString().substring(0,1);
                  int contador = 1;
                  for(Conta conta in widget.contasContabeis){
                    if(conta.numeroconta.substring(0,1) == nivel1
                        && conta.nivel2 != "00" && conta.nivel3 == "00" && conta.nivel4 == "000") {
                      contador++;
                    }
                  }
                  int tamanhoNivel2 = contador.toString().length;
                  if(tamanhoNivel2 == 1){
                    nivel2 = "0$contador";
                  }else{
                    nivel2 = "$contador";
                  }
                }

                // aqui inserimos os dados informados e tratados para o cadastro no banco de dados
                basededadosfirestore.collection("planodecontas").doc().set(
                    {
                      "conta" : nivel1 == "1" || nivel1 == "2" ? "patrimonial" : "resultado",
                      "localizacao" : valorLocalizacao,
                      "natureza" : valorNatureza,
                      "nivel1" : nivel1,
                      "nivel2" : nivel2,
                      "nivel3" : nivel3,
                      "nivel4" : nivel4,
                      "nivel5" : nivel5,
                      "nomeconta" : nomeConta,
                      "numeroconta" : "$nivel1.$nivel2.$nivel3.$nivel4.$nivel5",
                      "numeroreduzido" : valorNivelQuatro == null ? "N/A" : numeroReduzidaConta,
                      "tipodeconta" : valorNivelQuatro == null ? "sintetica" : "analitica"
                    }
                ).catchError((erro){setState(() { msg = erro; });}).whenComplete(() => Navigator.pop(context));
              }
            }
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  // funcao para retornar lista de conta patrimonial conforme nivel e campo do cadastro
  contaPatrimonial(List<String> lista, String valorEscolhido){

    retornarValorEscolhido(valor){
      if(valorEscolhido == "nivel1") {
        return valorNivelUm;
      }
      if(valorEscolhido == "nivel2") {
        return valorNivelDois;
      }
      if(valorEscolhido == "nivel3") {
        return valorNivelTres;
      }
      if(valorEscolhido == "nivel4") {
        return valorNivelQuatro;
      }
      if(valorEscolhido == "localizacao") {
        return valorLocalizacao;
      }
      if(valorEscolhido == "natureza") {
        return valorNatureza;
      }
    }

    retornarLocalizacao(var numConta){
      String numero = numConta.toString().substring(0,17);
      String retorno = "";
      for(var conta in widget.contasContabeis){
        if(conta.numeroconta == numero) {
          retorno = conta.localizacao;
        }
      }
      return retorno;
    }

    retornarNatureza(var localizacao){
      if(localizacao == "Ativo"){
        return "Devedora";
      }else if(localizacao == "Passivo"){
        return "Credora";
      }else if(localizacao == "Patrimônio Líquido"){
        return "Credora";
      }else if(localizacao == "Receita"){
        return "Credora";
      }else if(localizacao == "Custo"){
        return "Devedora";
      }else if(localizacao == "Despesa"){
        return "Devedora";
      }
    }

    List<String> retornarLista(String filtroLista){
      if(valorEscolhido == "nivel1") {
        return nivelUm;
      }else if(valorEscolhido == "nivel2") {
        return nivelDois;
      }else if(valorEscolhido == "nivel3") {
        return nivelTres;
      }else if(valorEscolhido == "nivel4") {
        return nivelQuatro;
      }else if(valorEscolhido == "localizacao") {
        return localizacao;
      }else if(valorEscolhido == "natureza") {
        return natureza;
      }else{
        return [];
      }
    }

    buscarListaSegundoNivel(var numConta){
      String numero = numConta.toString().substring(0,1);
      List<String> lista = [];
      for(Conta conta in widget.contasContabeis){
        if(conta.numeroconta.substring(0,1) == numero && conta.nivel2 != "00" && conta.nivel3 == "00" && conta.nivel4 == "000" && conta.nivel5 == "00000") {
          lista.add("${conta.numeroconta} ${conta.nomeconta}");
        }
      }
      return lista;
    }

    buscarListaTerceiroNivel(var numConta){
      String numero = numConta.toString().substring(0,4);
      List<String> lista = [];
      for(Conta conta in widget.contasContabeis){
        if(conta.numeroconta.substring(0,4) == numero && conta.nivel3 != "00" && conta.nivel4 == "000" && conta.nivel5 == "00000") {
          lista.add("${conta.numeroconta} ${conta.nomeconta}");
        }
      }
      return lista;
    }

    buscarListaQuartoNivel(var numConta){
      String numero = numConta.toString().substring(0,7);
      List<String> lista = [];
      for(Conta conta in widget.contasContabeis){
        if(conta.numeroconta.substring(0,7) == numero && conta.nivel4 != "000" && conta.nivel5 == "00000") {
          lista.add("${conta.numeroconta} ${conta.nomeconta}");
        }
      }
      return lista;
    }

    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
            flex: 5,
            child: Container(
              height: 50,
              child: DropdownButton<String>(
                value: retornarValorEscolhido(valorEscolhido),
                isExpanded: true,
                items: retornarLista(valorEscolhido).map(
                    (String item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    )
                ).toList(),
                onChanged: (valor) => setState(() {
                  if(valorEscolhido == "nivel1") {
                    setState(() {
                      valorNivelUm = valor;
                      valorNivelDois = null;
                      valorNivelTres = null;
                      valorNivelQuatro = null;
                      valorNivelCinco = null;
                      valorLocalizacao = retornarLocalizacao(valor);
                      valorNatureza = retornarNatureza(valorLocalizacao);
                      nivelDois = buscarListaSegundoNivel(valor);
                      nivelTres = [];
                      nivelQuatro = [];
                    });
                  }
                  if(valorEscolhido == "nivel2") {
                    setState(() {
                      valorNivelDois = valor;
                      valorNivelTres = null;
                      valorNivelQuatro = null;
                      valorNivelCinco = null;
                      nivelTres = buscarListaTerceiroNivel(valor);
                      nivelQuatro = [];
                    });
                  }
                  if(valorEscolhido == "nivel3") {
                    setState(() {
                      valorNivelTres = valor;
                      valorNivelQuatro = null;
                      valorNivelCinco = null;
                      nivelQuatro = buscarListaQuartoNivel(valor);
                    });
                  }
                  if(valorEscolhido == "nivel4") {
                    setState(() {
                      valorNivelQuatro = valor;
                      valorNivelCinco = null;
                    });
                  }
                  if(valorEscolhido == "localizacao") {
                    setState(() {
                      valorLocalizacao = valor;
                      valorNatureza = retornarNatureza(valorLocalizacao.toString());
                    });
                  }
                  if(valorEscolhido == "natureza") {
                    setState(() {
                      valorNatureza = valor;
                    });
                  }
                }),
              ),
            )
        ),
        Expanded(child: Container()),
      ],
    );
  }

  // funcao para retornar campo de texto que será preenchido pelo usuario
  campoDeTexto(String tipo){
    return Row(
      children: [
        Expanded(child: Container()),
        Expanded(
            flex: 5,
            child: Container(
              height: 50,
              child: TextField(
                decoration: InputDecoration(
                  labelText: tipo == "nome" ? "Nome da Conta" : "Código Reduzida"
                ),
                keyboardType: tipo == "nome" ? TextInputType.text : TextInputType.number,
                inputFormatters: tipo == "nome" ?
                [] :
                <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                controller: tipo == "nome" ? nomeContaController : numeroReduzidaContaController,
                onChanged: (text){
                  if(tipo == "nome"){
                    setState(() { nomeConta = text.toString(); });
                  }else{
                    setState(() { numeroReduzidaConta = text.toString(); });
                  }
                },
              ),
            )
        ),
        Expanded(child: Container()),
      ],
    );
  }

  // funcao para buscar contas sinteticas de primeiro nivel
  tratarContasEmNiveis(){
    for(Conta conta in widget.contasContabeis){
      if(conta.nivel2 == "00" && conta.nivel3 == "00" && conta.nivel4 == "000" && conta.nivel5 == "00000" ) {
        setState(() { nivelUm.add("${conta.numeroconta} ${conta.nomeconta}"); });
      }
    }
  }

}
