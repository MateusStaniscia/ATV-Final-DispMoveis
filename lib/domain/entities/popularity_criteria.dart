class PopularityCriteria {
  final String id;
  final String name;
  final String description;

  const PopularityCriteria({
    required this.id,
    required this.name,
    required this.description,
  });

  static const List<PopularityCriteria> values = [
    PopularityCriteria(
      id: 'resenha',
      name: 'Resenha',
      description: 'Mede o quanto o aluno anima a turma, puxa conversa e contribui para deixar o ambiente mais descontraído.',
    ),
    PopularityCriteria(
      id: 'presenca_vip',
      name: 'Presença VIP',
      description: 'Avalia o quanto o aluno é lembrado, percebido ou reconhecido pelos colegas no dia a dia da turma.',
    ),
    PopularityCriteria(
      id: 'aura',
      name: 'Aura',
      description: 'Representa a energia geral do aluno: presença, estilo, jeito de ser e impacto que causa no ambiente.',
    ),
    PopularityCriteria(
      id: 'modo_parceiro',
      name: 'Modo Parceiro',
      description: 'Mede o quanto o aluno ajuda os colegas, colabora nas atividades e demonstra espírito de parceria.',
    ),
    PopularityCriteria(
      id: 'carisma_natural',
      name: 'Carisma Natural',
      description: 'Avalia a facilidade do aluno para socializar, conversar e criar boas relações com os colegas.',
    ),
    PopularityCriteria(
      id: 'humor_de_milhoes',
      name: 'Humor de Milhões',
      description: 'Representa o quanto o aluno contribui com bom humor, brincadeiras saudáveis e momentos divertidos.',
    ),
    PopularityCriteria(
      id: 'energia_de_grupo',
      name: 'Energia de Grupo',
      description: 'Mede a participação do aluno em trabalhos, eventos, jogos, dinâmicas e atividades coletivas da turma.',
    ),
    PopularityCriteria(
      id: 'criatividade_caotica',
      name: 'Criatividade Caótica',
      description: 'Avalia a capacidade do aluno de ter ideias diferentes, soluções inesperadas e comentários geniais.',
    ),
    PopularityCriteria(
      id: 'modo_atleta',
      name: 'Modo Atleta',
      description: 'Representa a aptidão esportiva, a disposição física e o espírito competitivo saudável do aluno.',
    ),
    PopularityCriteria(
      id: 'talento_de_palco',
      name: 'Talento de Palco',
      description: 'Mede a aptidão artística do aluno, como música, canto, instrumentos, dança, ritmo ou presença em apresentações.',
    ),
    PopularityCriteria(
      id: 'drip_escolar',
      name: 'Drip Escolar',
      description: 'Avalia o estilo pessoal do aluno, considerando roupas, tênis, cabelo, acessórios e presença visual.',
    ),
    PopularityCriteria(
      id: 'coracao_de_dorama',
      name: 'Coração de Dorama',
      description: 'Representa o carisma afetivo, a gentileza e aquela vibe de protagonista romântico, sem expor relacionamentos reais.',
    ),
    PopularityCriteria(
      id: 'queridinho_dos_professores',
      name: 'Queridinho dos Professores',
      description: 'Mede a boa relação do aluno com os professores, considerando respeito, participação, educação e responsabilidade.',
    ),
    PopularityCriteria(
      id: 'cerebro_turbo',
      name: 'Cérebro Turbo',
      description: 'Avalia o desempenho nos estudos, a facilidade para aprender, resolver problemas e se destacar academicamente.',
    ),
    PopularityCriteria(
      id: 'caos_controlado',
      name: 'Caos Controlado',
      description: 'Mede o quanto o aluno é bagunceiro, zoeiro ou imprevisível, mas ainda dentro dos limites do respeito e da convivência saudável.',
    ),
  ];
}
