/// O TVMaze devolve o resumo das series em HTML (ex.: "<p><b>Texto</b></p>").
/// Esta funcao remove as tags e converte as entidades mais comuns.
String stripHtml(String? html) {
  if (html == null || html.isEmpty) return '';

  final semTags = html.replaceAll(RegExp(r'<[^>]*>'), '');

  return semTags
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .trim();
}
