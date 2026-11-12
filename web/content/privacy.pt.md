---
title: "Política de Privacidade"
description: "Política de Privacidade do AISight. Não recolhemos, armazenamos nem transmitimos os seus dados pessoais. O processamento de IA acontece por predefinição no seu dispositivo."
layout: "single"
---

# Política de Privacidade

*Última atualização: 11 de novembro de 2026*

## O Nosso Compromisso com a Privacidade

O AISight foi concebido com a privacidade como princípio fundamental. Não recolhemos, armazenamos nem transmitimos os seus dados pessoais para quaisquer servidores externos operados por nós. Não há análises, rastreamento, publicidade nem contas de utilizador. Os seus dados permanecem no seu dispositivo. As únicas exceções são os pedidos de rede e o processamento de IA descritos abaixo.

## Informações Que Não Recolhemos

O AISight não recolhe:

- Identificadores pessoais (nome, e-mail, número de telefone)
- Identificadores de dispositivo para fins de rastreamento
- Dados de localização
- Análises de utilização ou telemetria
- Identificadores publicitários
- Cookies ou impressões digitais do navegador

Nunca vendemos, alugamos, partilhamos ou monetizamos quaisquer dados de utilizadores — nunca.

## Dados Armazenados no Seu Dispositivo

O AISight armazena os seguintes dados localmente, apenas no seu dispositivo:

**Histórico de pesquisa:** As suas consultas de pesquisa e respostas geradas por IA são guardadas no seu dispositivo utilizando a framework SwiftData da Apple. Estes dados nunca saem do seu dispositivo, a menos que escolha partilhá-los.

**Preferências:** As definições da sua aplicação (preferências de idioma, URL do servidor SearXNG) são armazenadas em UserDefaults no seu dispositivo.

Pode eliminar todos os dados armazenados localmente a qualquer momento em Ajustes → Dados → Apagar Todos os Dados.

Definições do fornecedor de IA personalizado: se configurar um fornecedor de IA personalizado, o respetivo URL, nome do modelo e tamanho de contexto são guardados em UserDefaults no seu dispositivo, e a chave de API é guardada no Porta-chaves do dispositivo, apenas neste dispositivo. Apagar Todos os Dados em Ajustes também os remove.

## Dados Transmitidos Pela Rede

O AISight realiza até quatro tipos de pedidos de rede:

1. **Consultas de pesquisa:** Quando efetua uma pesquisa, a sua consulta é enviada para o servidor SearXNG que configurou. O AISight não opera este servidor — é você que o fornece e controla. A privacidade das suas consultas de pesquisa depende da configuração da sua instância SearXNG.

2. **Obtenção de conteúdo web:** O AISight obtém páginas web publicamente acessíveis a partir dos URLs devolvidos pelos resultados de pesquisa para extrair conteúdo de texto para síntese com IA. Estes são pedidos HTTP padrão, semelhantes a visitar um website num navegador.

O AISight não adiciona parâmetros de rastreamento, cabeçalhos personalizados ou informações identificativas a estes pedidos para além do que é padrão para o carregamento de URLs no iOS/macOS.

3. Apple Private Cloud Compute (opcional): Apenas se o ativar em Ajustes, a sua pergunta, o texto extraído das fontes web e as instruções de IA são enviados para o serviço Private Cloud Compute da Apple para escrever a resposta.

4. Fornecedor de IA personalizado (opcional): Apenas se configurar um e confirmar o aviso em Ajustes, a sua pergunta, o texto extraído das fontes web e as instruções de IA são enviados para o servidor desse fornecedor. A Pesquisa Profunda envia vários pedidos por pergunta. Aplicam-se os termos e as práticas de privacidade do próprio fornecedor.

## Processamento de IA

Por predefinição, todo o processamento de IA no AISight acontece inteiramente no seu dispositivo utilizando a framework FoundationModels da Apple (Apple Intelligence). As suas consultas, resultados de pesquisa e respostas geradas não são enviados para qualquer serviço de IA na nuvem. Se escolher «Apple Private Cloud Compute» em Ajustes → Modelo de IA, a sua consulta e os resultados de pesquisa necessários para escrever uma resposta são, em vez disso, processados nos servidores Private Cloud Compute da Apple, com as proteções de privacidade da Apple para esse serviço. Pode voltar ao processamento no dispositivo a qualquer momento. Se configurar um fornecedor de IA personalizado em Ajustes → Modelo de IA e confirmar o aviso, a sua pergunta, o texto extraído das fontes web e as instruções de IA são enviados para esse fornecedor, ao abrigo dos termos desse fornecedor; a Pesquisa Profunda envia vários pedidos. A chave de API é guardada no Porta-chaves do seu dispositivo e só é enviada para esse fornecedor.

## Serviços de Terceiros

O AISight em si não se integra com quaisquer serviços de análise, publicidade, relatórios de falhas ou recolha de dados de terceiros.

A sua instância SearXNG auto-alojada pode ter as suas próprias práticas de dados dependendo de como está configurada. Recomendamos que consulte a documentação do SearXNG para mais detalhes.

As páginas web obtidas durante a pesquisa podem conter os seus próprios mecanismos de rastreamento, mas o AISight apenas extrai conteúdo em texto simples e não executa JavaScript nem carrega recursos de rastreamento.

## Privacidade das Crianças

O AISight não recolhe conscientemente qualquer informação pessoal de ninguém, incluindo crianças menores de 13 anos. Uma vez que não recolhemos dados pessoais, não há dados de crianças para gerir. No entanto, o conteúdo gerado por IA pode nem sempre ser apropriado para todas as idades. Recomenda-se orientação parental.

## Os Seus Direitos

Uma vez que o AISight não recolhe nem armazena os seus dados pessoais em qualquer servidor externo, muitos direitos tradicionais de dados são satisfeitos por design:

- **Direito de acesso:** Todos os seus dados são armazenados localmente no seu dispositivo e são acessíveis a si.
- **Direito à eliminação:** Pode eliminar todos os dados da aplicação em Ajustes a qualquer momento, ou eliminando a aplicação.
- **Direito à portabilidade dos dados:** Os seus dados são armazenados em formatos padrão no seu dispositivo.
- **Direito de recusar a venda:** Nunca vendemos os seus dados.

Estes direitos aplicam-se a utilizadores de todas as jurisdições, incluindo ao abrigo do Regulamento Geral sobre a Proteção de Dados (RGPD) da UE e da Lei de Privacidade do Consumidor da Califórnia (CCPA).

## Segurança

Os seus dados são protegidos pelas funcionalidades de segurança integradas no seu dispositivo Apple, incluindo encriptação do dispositivo, sandboxing de aplicações e bloqueios biométricos ou por código. Uma vez que o AISight armazena dados apenas no seu dispositivo utilizando as frameworks da Apple, os seus dados beneficiam da arquitetura de segurança completa do iOS e macOS.

Os pedidos de rede para a sua instância SearXNG e websites de origem utilizam encriptação HTTPS padrão quando o servidor o suporta.

## Retenção de Dados

O histórico de pesquisa é mantido no seu dispositivo até que o elimine explicitamente. Nenhum dado é retido em qualquer servidor externo operado por nós. Quando elimina a aplicação, todos os dados armazenados localmente são removidos. Apagar Todos os Dados em Ajustes também remove a chave de API e as definições do seu fornecedor personalizado.

## Este Website

Este website (private-search-intelligence.app) não utiliza cookies, análises nem rastreamento. O formulário de contacto envia a sua mensagem diretamente por e-mail e não armazenamos os seus dados em qualquer servidor.

## Alterações a Esta Política

Podemos atualizar esta política de privacidade periodicamente. As alterações serão refletidas na aplicação com uma data de "Última atualização" atualizada. O uso continuado da aplicação após as alterações constitui aceitação da política atualizada.

## Contacto

Se tiver questões sobre esta política de privacidade, por favor contacte-nos em [jesus@perezpaz.es](mailto:jesus@perezpaz.es).
