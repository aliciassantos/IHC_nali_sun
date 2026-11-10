// Fonte de dados para artigos e dicas

import '../models/article_model.dart';

class ArticleRepository {
  static const String _imagemPadrao = 'assets/img/plantinha1.jpg';

  // =========================================================
  // 12 ARTIGOS ESTÁTICOS DA ABA DE DICAS
  // =========================================================

  static const List<ArticleModel> _dicasGerais = [
    // 1. SUBSTRATO
    ArticleModel(
      titulo: 'O segredo está embaixo: substrato ideal para cada planta',
      categoria: 'SUBSTRATO',
      resumo: 'Descubra como escolher o substrato adequado para suas plantas.',
      conteudo: '''
O substrato é um dos elementos mais importantes para o desenvolvimento de uma planta. É nele que as raízes encontram sustentação, água e parte dos nutrientes necessários para crescer. Escolher uma mistura adequada ajuda a manter o equilíbrio entre umidade, drenagem e circulação de ar.

Cada espécie possui necessidades diferentes. Algumas plantas preferem um substrato que retenha um pouco mais de umidade, enquanto outras precisam de uma mistura mais leve, que permita a saída rápida do excesso de água. Por isso, não existe uma receita universal que funcione para todas as plantas.

Materiais como fibra de coco, casca de pinus, areia própria para jardinagem e perlita podem ser utilizados em diferentes combinações, dependendo da espécie. O importante é entender a função de cada componente antes de preparar a mistura.

Um sinal de que o substrato pode não estar adequado é a dificuldade de drenagem, o encharcamento frequente ou a compactação excessiva. Observe também o desenvolvimento das raízes e a condição das folhas.

Antes de trocar o substrato, pesquise as necessidades específicas da planta. Uma boa escolha pode favorecer o crescimento e ajudar a evitar problemas relacionados ao excesso ou à falta de água.
''',
      imagem: '../assets/img/substrato.jpg',
    ),

    // 2. REGA
    ArticleModel(
      titulo: 'Na hora de regar, observe mais do que o calendário',
      categoria: 'REGA',
      resumo: 'Aprenda a identificar quando sua planta realmente precisa de água.',
      conteudo: '''
A rega é um dos cuidados mais importantes para manter uma planta saudável. Entretanto, regar todos os vasos no mesmo dia e na mesma quantidade pode não ser uma boa estratégia. Cada espécie possui necessidades próprias, e diversos fatores influenciam a velocidade com que o substrato perde água.

A temperatura, a umidade do ambiente, a quantidade de luz recebida, o tamanho do vaso e o tipo de substrato podem alterar a frequência necessária de rega. Em dias mais quentes, por exemplo, algumas plantas podem perder água mais rapidamente. Em períodos frios ou úmidos, a secagem pode demorar mais.

Antes de regar, observe a umidade do substrato. Em muitos casos, tocar levemente a superfície já ajuda a perceber se ainda existe umidade. Para vasos maiores, pode ser necessário verificar uma região um pouco mais profunda.

Evite deixar água acumulada no pratinho por longos períodos. O excesso de umidade pode reduzir a circulação de ar nas raízes e favorecer seu apodrecimento.

O calendário de rega deve funcionar como um lembrete, não como uma obrigação. Aprenda a observar sua planta e adapte os cuidados às condições do ambiente.
''',
      imagem: '../assets/img/rega.jpg',
    ),

    // 3. ILUMINAÇÃO
    ArticleModel(
      titulo: 'Luz direta ou indireta: onde colocar suas plantas?',
      categoria: 'ILUMINAÇÃO',
      resumo: 'Entenda as diferenças entre os tipos de iluminação.',
      conteudo: '''
A iluminação influencia diretamente o crescimento das plantas. Por meio da luz, elas realizam a fotossíntese, processo fundamental para produzir os compostos necessários ao seu desenvolvimento. Porém, nem todas as espécies precisam da mesma quantidade de luz.

A luz direta acontece quando os raios solares atingem diretamente as folhas. Algumas plantas estão adaptadas a essa condição e conseguem receber várias horas de sol. Outras são mais sensíveis e podem apresentar queimaduras quando expostas ao sol intenso.

A luz indireta ocorre quando o ambiente recebe claridade, mas os raios solares não atingem diretamente a planta. Esse tipo de iluminação costuma ser adequado para diversas espécies cultivadas dentro de casa.

Observe os sinais apresentados pelas folhas. Folhas queimadas, manchas secas e alterações na coloração podem indicar exposição inadequada. Já o crescimento muito alongado e o enfraquecimento da planta podem estar relacionados à falta de iluminação.

Antes de escolher o local definitivo, pesquise as necessidades da espécie. Também evite mudanças muito bruscas, permitindo que a planta se adapte gradualmente a uma nova condição de luz.
''',
      imagem: '../assets/img/iluminacao.jpg',
    ),

    // 4. PODA
    ArticleModel(
      titulo: 'Poda consciente: quando e como cortar sem estressar a planta',
      categoria: 'PODA',
      resumo: 'Aprenda a remover folhas e galhos com cuidado.',
      conteudo: '''
A poda é uma prática utilizada para remover partes secas, danificadas, doentes ou que estejam prejudicando o formato da planta. Quando realizada corretamente, ela pode contribuir para a manutenção e o desenvolvimento saudável do vegetal.

Antes de começar, observe quais partes realmente precisam ser removidas. Folhas completamente secas ou galhos danificados podem ser retirados com cuidado. Evite podar apenas por estética sem conhecer as necessidades da espécie.

Utilize tesouras apropriadas e limpas. Ferramentas sujas podem transportar microrganismos de uma planta para outra. Os cortes devem ser realizados com cuidado, evitando ferimentos desnecessários no caule.

Também é importante não retirar uma quantidade excessiva de folhas de uma só vez. As folhas participam da fotossíntese, e uma poda muito intensa pode dificultar a recuperação da planta.

Algumas espécies possuem épocas mais adequadas para poda, especialmente aquelas que florescem em períodos específicos do ano. Por isso, pesquise antes de realizar cortes mais intensos.

Lembre-se: podar não significa cortar o máximo possível. O objetivo é remover o que está prejudicando a planta e respeitar seu ritmo natural de crescimento.
''',
      imagem: '../assets/img/poda.jpg',
    ),

    // 5. ADUBAÇÃO
    ArticleModel(
      titulo: 'Adubação: como oferecer nutrientes sem exagerar',
      categoria: 'ADUBAÇÃO',
      resumo: 'Conheça a importância dos nutrientes para o crescimento.',
      conteudo: '''
Assim como outros seres vivos, as plantas precisam de nutrientes para realizar suas funções e se desenvolver. Alguns desses nutrientes são encontrados naturalmente no ambiente, enquanto outros podem ser complementados por meio da adubação.

A adubação consiste em fornecer nutrientes ao solo ou substrato utilizando fertilizantes adequados. Entre os nutrientes importantes estão nitrogênio, fósforo e potássio, que participam de diferentes processos do desenvolvimento vegetal.

O nitrogênio está relacionado ao crescimento vegetativo e à formação de folhas. O fósforo participa de processos ligados ao desenvolvimento das raízes, enquanto o potássio contribui para diversas funções metabólicas da planta.

Entretanto, utilizar mais fertilizante não significa conseguir melhores resultados. O excesso pode provocar acúmulo de sais no substrato, prejudicar as raízes e causar alterações nas folhas.

Antes de adubar, verifique se a planta realmente precisa de nutrientes adicionais. Escolha produtos adequados à espécie e siga as orientações de aplicação indicadas pelo fabricante.

Uma rotina equilibrada de adubação, associada à iluminação e à rega adequadas, ajuda a manter melhores condições para o desenvolvimento da planta.
''',
      imagem: '../assets/img/adubacao.jpg',
    ),

    // 6. DRENAGEM
    ArticleModel(
      titulo: 'A importância dos furos de drenagem nos vasos',
      categoria: 'VASOS',
      resumo: 'Entenda por que a drenagem é essencial para as raízes.',
      conteudo: '''
Você já percebeu que alguns vasos possuem pequenos furos na parte inferior? Eles não estão ali apenas por uma questão de fabricação. Esses furos desempenham uma função importante: permitir que o excesso de água saia do recipiente.

Quando a água permanece acumulada no fundo do vaso, o substrato pode ficar encharcado por muito tempo. Essa condição reduz a disponibilidade de oxigênio para as raízes e pode favorecer problemas como o apodrecimento radicular.

Por isso, na maioria dos cultivos em vasos, é importante utilizar recipientes com furos de drenagem adequados. Também é necessário escolher um substrato que permita a circulação de água e ar.

Outro cuidado importante é observar o pratinho colocado embaixo do vaso. Ele pode recolher a água que escorre durante a rega, mas não deve permanecer constantemente cheio.

A drenagem precisa funcionar em conjunto com a escolha do substrato e a frequência de rega. Mesmo um vaso com furos pode apresentar problemas quando recebe água em excesso.

Antes de escolher um recipiente, considere o tamanho da planta, suas raízes e as necessidades específicas da espécie.
''',
      imagem: '../assets/img/vasos.jpg',
    ),

    // 7. LIMPEZA DAS FOLHAS
    ArticleModel(
      titulo: 'Folhas limpas também fazem parte dos cuidados',
      categoria: 'MANUTENÇÃO',
      resumo: 'Veja como remover a poeira acumulada nas folhas.',
      conteudo: '''
As folhas são estruturas essenciais para a realização da fotossíntese. Durante a rotina de cuidados, é comum prestar atenção à rega e à iluminação, mas a limpeza também merece atenção.

Em ambientes internos, a poeira pode se acumular na superfície das folhas. Esse acúmulo deixa a planta com aparência opaca e dificulta a observação de sua condição.

Em espécies com folhas adequadas para esse tipo de cuidado, a limpeza pode ser feita com um pano macio e levemente umedecido. Realize movimentos delicados, sem pressionar ou esfregar excessivamente.

Evite utilizar produtos de limpeza doméstica, detergentes ou receitas caseiras sem orientação específica. Algumas substâncias podem danificar a superfície das folhas.

Plantas com folhas muito delicadas, pilosas ou com características especiais podem precisar de outra forma de manutenção. Pesquise as recomendações para a sua espécie antes de realizar a limpeza.

Esse momento também pode ser utilizado para observar possíveis alterações. Manchas, pequenos furos, deformações ou presença de insetos merecem atenção.

Além de melhorar a aparência, a manutenção permite acompanhar mais de perto a saúde da planta.
''',
      imagem: '../assets/img/manutencao.jpg',
    ),

    // 8. PRAGAS
    ArticleModel(
      titulo: 'Como identificar sinais de pragas nas plantas',
      categoria: 'PREVENÇÃO',
      resumo: 'Aprenda a observar folhas, caules e substrato.',
      conteudo: '''
As plantas podem ser atacadas por diferentes organismos, incluindo pulgões, cochonilhas, ácaros e outros insetos. Identificar os sinais no início pode ajudar a evitar que o problema se espalhe e comprometa outras plantas.

Alguns sinais que merecem atenção são folhas amareladas, manchas incomuns, pequenos furos, deformações e presença de substâncias pegajosas. Em determinadas infestações, também podem aparecer pequenos pontos ou teias na parte inferior das folhas.

Durante a inspeção, observe tanto a parte superior quanto a inferior das folhas. Confira também os caules, os brotos novos e a região próxima ao substrato.

Caso identifique uma possível praga, procure reconhecer o organismo antes de escolher um tratamento. Diferentes pragas exigem medidas diferentes, e uma aplicação inadequada pode prejudicar a planta.

Quando possível, mantenha temporariamente a planta afetada separada das demais até compreender o problema. Isso pode ajudar a reduzir o risco de disseminação.

A inspeção frequente é uma forma simples de acompanhar a saúde do jardim. Quanto mais cedo um problema for percebido, maiores podem ser as possibilidades de controlar a situação.
''',
      imagem: '../assets/img/prevencao.jpg',
    ),

    // 9. REPLANTIO
    ArticleModel(
      titulo: 'Quando é hora de trocar sua planta de vaso?',
      categoria: 'REPLANTIO',
      resumo: 'Conheça os sinais de que sua planta pode precisar de mais espaço.',
      conteudo: '''
O replantio consiste em transferir uma planta para outro recipiente ou renovar o substrato em que ela está sendo cultivada. Essa prática pode ser necessária conforme a planta cresce e suas raízes ocupam o espaço disponível.

Um dos sinais que merecem atenção é a presença de raízes saindo pelos furos de drenagem. Também pode acontecer de o substrato secar muito rapidamente ou de a planta apresentar pouco espaço para continuar se desenvolvendo.

Entretanto, esses sinais precisam ser avaliados em conjunto. Algumas plantas possuem raízes naturalmente aparentes ou preferem recipientes mais ajustados.

Ao escolher um novo vaso, procure um tamanho compatível com a planta e que possua furos de drenagem. Um recipiente muito grande pode reter um volume de água desnecessário em relação ao tamanho das raízes.

Durante a transferência, manuseie as raízes com cuidado e evite remover partes saudáveis sem necessidade.

Depois do replantio, acompanhe a adaptação da planta e evite mudanças bruscas na iluminação e no ambiente. Cada espécie possui características próprias, por isso é importante pesquisar as recomendações específicas antes de realizar a troca.
''',
      imagem: '../assets/img/replantio.jpg',
    ),

    // 10. AMBIENTE
    ArticleModel(
      titulo: 'O ambiente também influencia a saúde das plantas',
      categoria: 'AMBIENTE',
      resumo: 'Temperatura, ventilação e umidade merecem atenção.',
      conteudo: '''
Quando pensamos nos cuidados com as plantas, geralmente lembramos da água e da luz. Entretanto, as condições do ambiente também exercem influência importante sobre seu desenvolvimento.

A temperatura pode interferir na velocidade de crescimento, na perda de água e em diferentes processos metabólicos. Cada espécie possui uma faixa de condições ambientais em que tende a se desenvolver melhor.

A umidade do ar também merece atenção. Algumas plantas são adaptadas a ambientes mais úmidos, enquanto outras toleram melhor condições relativamente secas.

A ventilação ajuda na circulação do ar ao redor das folhas e pode contribuir para reduzir o acúmulo excessivo de umidade. Porém, correntes de ar muito fortes podem prejudicar determinadas espécies.

Observe onde sua planta está posicionada. Ambientes próximos a aparelhos de ar-condicionado, aquecedores ou janelas com exposição intensa podem apresentar condições diferentes do restante da casa.

Antes de escolher o local definitivo, procure conhecer as preferências da espécie. Um ambiente adequado não depende apenas de beleza, mas também das condições necessárias para o desenvolvimento saudável da planta.
''',
      imagem: '../assets/img/ambientecomplanta.jpg',
    ),

    // 11. BEM-ESTAR
    ArticleModel(
      titulo: 'Ter plantas em casa vai além da decoração',
      categoria: 'BEM-ESTAR',
      resumo: 'Descubra como o cultivo pode fazer parte da sua rotina.',
      conteudo: '''
As plantas podem transformar a aparência de um ambiente e aproximar as pessoas do contato com a natureza. Mas o cultivo também pode representar uma experiência de aprendizagem e cuidado.

Acompanhar o crescimento de uma planta exige observação. É necessário perceber mudanças nas folhas, acompanhar o desenvolvimento de novos brotos e compreender as necessidades de cada espécie.

Essa rotina pode incentivar momentos de pausa durante o dia. Regar, retirar folhas secas e organizar os vasos são atividades que podem ser incorporadas aos cuidados cotidianos.

As plantas também ajudam a compor ambientes mais acolhedores e podem estimular o interesse pela jardinagem, pela sustentabilidade e pelo conhecimento sobre a natureza.

Não é necessário ter um espaço grande para começar. Uma pequena planta em um vaso já pode representar o início de um jardim.

Escolha espécies compatíveis com o espaço e com o tempo disponível para os cuidados. O mais importante é compreender que cada planta possui um ritmo próprio e precisa de atenção adequada.
''',
      imagem: '../assets/img/bem_estar.jpg',
    ),

    // 12. PROPAGAÇÃO
    ArticleModel(
      titulo: 'Como multiplicar plantas por estaquia?',
      categoria: 'PROPAGAÇÃO',
      resumo: 'Aprenda como produzir novas mudas a partir de uma planta.',
      conteudo: '''
A estaquia é uma técnica de propagação vegetal utilizada para produzir novas plantas a partir de partes de uma planta já existente. Dependendo da espécie, podem ser utilizados segmentos de caule, folhas ou outras estruturas vegetais.

O primeiro passo é escolher uma planta saudável. Evite retirar partes de exemplares que apresentem sinais de doenças, pragas ou condições muito debilitadas.

Utilize uma ferramenta limpa e apropriada para realizar o corte. O segmento escolhido deve apresentar características adequadas à espécie, pois nem toda planta consegue se desenvolver a partir do mesmo tipo de estaquia.

Depois da preparação, a muda pode ser colocada em água ou em um substrato apropriado, conforme o método recomendado para aquela planta. Durante esse período, acompanhe a umidade e mantenha condições ambientais adequadas.

O surgimento de raízes pode levar dias ou semanas, dependendo da espécie, da temperatura e das condições de cultivo. Por isso, tenha paciência e evite manipular a muda constantemente.

A estaquia é uma maneira interessante de multiplicar plantas e ampliar o jardim. Antes de começar, pesquise o método mais indicado para a espécie que deseja reproduzir.
''',
      imagem: '../assets/img/propagacao.jpg',
    ),
  ];

  // =========================================================
  // MÉTODOS DE ACESSO AOS ARTIGOS
  // =========================================================

  /// Retorna todos os artigos estáticos disponíveis.
  static List<ArticleModel> getGeneralTips() {
    return _dicasGerais;
  }

  /// Retorna a quantidade total de artigos.
  static int get totalArtigos => _dicasGerais.length;
}

