// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get brandingTagline => 'Chat de voz e vídeo para a sua comunidade';

  @override
  String get brandingSignIn => 'Entrar';

  @override
  String brandingSignInWith(String provider) {
    return 'Entrar com $provider';
  }

  @override
  String brandingHostedBy(String community) {
    return 'Hospedado por $community.';
  }

  @override
  String get signInServers => 'Servidores';

  @override
  String get signInUnreachable => 'Não foi possível acessar o servidor.';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get signInInBrowser => 'Continue no navegador…';

  @override
  String get signInAccountHelp =>
      'Seu nome, sua foto e suas convocações acompanham você em qualquer lugar.';

  @override
  String get signInOr => 'ou';

  @override
  String get signInGuest => 'Entrar como convidado';

  @override
  String get signInGuestName => 'Seu nome';

  @override
  String get signInGuestHelp =>
      'Convidados podem falar e ouvir, mas não podem compartilhar vídeo nem ser chamados.';

  @override
  String get signInJoining => 'Entrando…';

  @override
  String get signInAsGuest => 'Continuar como convidado';

  @override
  String get signInNobody =>
      'Este servidor não está deixando ninguém entrar agora.';

  @override
  String get signInGuestsClosed =>
      'O acesso de convidados está fechado por enquanto.';

  @override
  String get signInEncrypted =>
      'As chamadas têm criptografia de ponta a ponta.';

  @override
  String get signInNameLength => 'Um nome tem de 1 a 32 caracteres.';

  @override
  String get callMute => 'Silenciar';

  @override
  String get callUnmute => 'Ativar som';

  @override
  String get callCameraOn => 'Ligar câmera';

  @override
  String get callCameraOff => 'Desligar câmera';

  @override
  String get callShareScreen => 'Compartilhar tela';

  @override
  String get callStopSharing => 'Parar de compartilhar';

  @override
  String get callLeave => 'Sair';

  @override
  String get callServiceChannel => 'Chamadas';

  @override
  String get callServiceInCall => 'Em uma chamada de voz';

  @override
  String get callServiceSharing => 'Compartilhando sua tela';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsSystemDefault => 'Padrão do sistema';

  @override
  String get settingsDone => 'Concluído';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatVanishes => 'As mensagens somem 4 h depois da última';

  @override
  String chatClearsInHours(int hours, int minutes) {
    return 'Será apagado em $hours h $minutes min se ninguém escrever';
  }

  @override
  String chatClearsInMinutes(int minutes) {
    return 'Será apagado em $minutes min se ninguém escrever';
  }

  @override
  String get chatClose => 'Fechar chat';

  @override
  String get chatEmpty => 'Nenhuma mensagem ainda. Diga oi!';

  @override
  String get chatLoading => 'Carregando…';

  @override
  String get chatGettingKey => 'Obtendo a chave do chat…';

  @override
  String get chatSendingPicture => 'Enviando a imagem…';

  @override
  String get chatPreparingPicture => 'Preparando a imagem…';

  @override
  String get chatAddPicture => 'Adicionar imagem';

  @override
  String chatMessageTo(String channel) {
    return 'Mensagem em $channel';
  }

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatLocked =>
      'Criptografada com uma chave que este dispositivo não tem: enviada antes de ele entrar no chat.';

  @override
  String get chatGuest => 'convidado';

  @override
  String get chatDeleteMessage => 'Apagar mensagem';

  @override
  String get chatPictures => 'Imagens';

  @override
  String get chatInvalidMessage =>
      'Uma mensagem tem de 1 a 2000 caracteres, sem caracteres de controle.';

  @override
  String chatPictureNotSent(String reason) {
    return 'A imagem não foi enviada: $reason';
  }

  @override
  String get pictureFailed => 'A imagem não carregou';

  @override
  String get pictureTooLarge => 'Esta imagem é grande demais.';

  @override
  String get pictureUnreadable => 'Não é possível ler esta imagem.';

  @override
  String trustNewDevice(String name) {
    return '$name entrou de um dispositivo novo.';
  }

  @override
  String trustMineAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos novos entraram na sua conta.',
      many: '$count dispositivos novos entraram na sua conta.',
      one: 'Um dispositivo novo entrou na sua conta.',
    );
    return '$_temp0';
  }

  @override
  String get trustMineChanged =>
      'Atenção: um dispositivo da sua conta chegou com outra chave.';

  @override
  String get personKeyChanged =>
      'Cuidado: a chave do dispositivo desta pessoa mudou.';

  @override
  String get notificationOpen => 'Abrir';

  @override
  String get notificationChannel => 'Mensagens e convocações';

  @override
  String notificationSummonTitle(String caller) {
    return '$caller está chamando você';
  }

  @override
  String notificationSummonBody(String channel) {
    return 'Entre em $channel';
  }

  @override
  String get signInErrorRefused => 'O login foi cancelado.';

  @override
  String get signInErrorExpired => 'O login demorou demais. Tente de novo.';

  @override
  String get signInErrorBanned => 'Esta conta está banida neste servidor.';

  @override
  String get signInErrorUnavailable =>
      'O login com conta não está disponível no momento.';

  @override
  String get signInErrorFailed => 'Falha no login. Tente de novo.';

  @override
  String get signInNoBrowser =>
      'Não foi possível abrir o navegador para entrar.';

  @override
  String get signInBrowserDone =>
      'Você entrou. Pode fechar esta aba e voltar ao Wisetalk.';

  @override
  String get signInBrowserFailed =>
      'Não foi possível entrar. Volte ao Wisetalk para tentar de novo.';

  @override
  String get updatesNotSelfUpdating =>
      'Esta versão do Wisetalk não se atualiza sozinha.';

  @override
  String get updatesCannotCheck =>
      'Não foi possível verificar se há atualizações. Tente mais tarde.';

  @override
  String updatesReady(String version) {
    return 'O Wisetalk $version está pronto: reinicie para atualizar.';
  }

  @override
  String updatesAvailable(String version) {
    return 'O Wisetalk $version saiu: atualize para $version.';
  }

  @override
  String updatesLatest(String version) {
    return 'O Wisetalk $version é a versão mais recente.';
  }

  @override
  String get voiceMutedByModerator =>
      'Um moderador silenciou você, e só ele pode desfazer isso.';

  @override
  String get voiceCameraUnavailable => 'Câmera indisponível.';

  @override
  String get voiceCannotSwitchCamera =>
      'Não foi possível mudar para essa câmera.';

  @override
  String get voiceScreenUnavailable => 'Compartilhamento de tela indisponível.';

  @override
  String get voiceServerMuted => 'Um moderador silenciou você.';

  @override
  String get voiceServerUnmuted =>
      'Um moderador tirou seu silenciamento. Ative o microfone quando quiser.';

  @override
  String voiceKicked(String reason) {
    return 'Você saiu do canal: $reason.';
  }

  @override
  String get voiceCannotConnect => 'Não foi possível conectar ao canal de voz.';

  @override
  String get voiceMicrophoneUnavailable =>
      'Microfone indisponível: você pode ouvir, mas não falar.';

  @override
  String get videoYou => 'Você';

  @override
  String connectionMilliseconds(int value) {
    return '$value ms';
  }

  @override
  String get connectionSignedOut => 'Sua sessão foi encerrada.';

  @override
  String get apiUnreachable => 'Não foi possível acessar o servidor.';

  @override
  String get apiUnreachableCheck =>
      'Não foi possível acessar o servidor. Verifique o endereço e a sua conexão.';

  @override
  String get apiNotWisetalk => 'Isso não parece um servidor Wisetalk.';

  @override
  String apiRefused(int status) {
    return 'O servidor recusou ($status).';
  }

  @override
  String get desktopComment => 'Chat de voz e vídeo para uma comunidade';

  @override
  String personYou(String name) {
    return '$name (você)';
  }

  @override
  String get personAudioVideoSettings => 'Configurações de áudio e vídeo…';

  @override
  String personVolume(int percent) {
    return 'Volume $percent%';
  }

  @override
  String get personMuteForMe => 'Silenciar para mim';

  @override
  String get personUnmuteForMe => 'Ativar som para mim';

  @override
  String get moderationServerMute => 'Silenciar no servidor';

  @override
  String get moderationLiftServerMute => 'Remover silêncio do servidor';

  @override
  String get moderationKick => 'Expulsar do canal';

  @override
  String get personMakeServerAdmin => 'Tornar administrador do servidor';

  @override
  String get personRemoveServerAdmin => 'Remover administrador do servidor';

  @override
  String personNowAdmin(String name) {
    return '$name agora é administrador do servidor.';
  }

  @override
  String personNowMember(String name) {
    return '$name agora é membro.';
  }

  @override
  String get moderationBan => 'Banir do servidor…';

  @override
  String moderationBanTitle(String name) {
    return 'Banir $name?';
  }

  @override
  String moderationBanConfirm(String name) {
    return 'Banir $name deste servidor? As sessões terminam na hora.';
  }

  @override
  String get moderationBanAction => 'Banir';

  @override
  String moderationBanned(String name) {
    return '$name foi banido.';
  }

  @override
  String get moderationBanGuest => 'Banir convidado por um dia…';

  @override
  String moderationBanGuestConfirm(String name) {
    return 'Remover $name e bloquear convidados desse endereço por um dia?';
  }

  @override
  String moderationGuestBanned(String name) {
    return '$name saiu; o endereço está bloqueado por um dia.';
  }

  @override
  String channelMakeOwner(String channel) {
    return 'Tornar dono de $channel';
  }

  @override
  String channelRemoveOwner(String channel) {
    return 'Remover como dono de $channel';
  }

  @override
  String channelNewOwner(String name, String channel) {
    return '$name agora é dono de $channel.';
  }

  @override
  String channelNoOwner(String channel) {
    return '$channel não tem mais dono.';
  }

  @override
  String spaceMakeOwner(String space) {
    return 'Tornar dono de $space';
  }

  @override
  String spaceRemoveOwner(String space) {
    return 'Remover como dono de $space';
  }

  @override
  String spaceNewOwner(String name, String space) {
    return '$name agora é dono de $space.';
  }

  @override
  String spaceNoOwner(String space) {
    return '$space não tem mais dono.';
  }

  @override
  String channelAudioStereo(int kbps) {
    return 'Áudio de até $kbps kbps, estéreo';
  }

  @override
  String channelAudioMono(int kbps) {
    return 'Áudio de até $kbps kbps, mono';
  }

  @override
  String get channelJoin => 'Entrar';

  @override
  String get channelOpenChat => 'Abrir chat';

  @override
  String get channelOpenSettings => 'Configurações do canal…';

  @override
  String get inviteCopyLink => 'Copiar link de convite';

  @override
  String inviteCopied(String channel) {
    return 'Link de convite para $channel copiado.';
  }

  @override
  String inviteCopiedWithKey(String channel) {
    return 'Convite para $channel copiado. Depois que alguém usar, ele deixa qualquer pessoa entrar por 10 minutos; sem uso, vale por um dia.';
  }

  @override
  String inviteCopiedRestricted(String channel) {
    return 'Link de convite para $channel copiado. Só funciona para quem o canal já deixa entrar.';
  }

  @override
  String get inviteCannotCreate => 'Não foi possível criar o convite.';

  @override
  String get spaceNewChannel => 'Novo canal no espaço…';

  @override
  String get spaceOpenSettings => 'Configurações do espaço…';

  @override
  String get spaceDelete => 'Excluir espaço…';

  @override
  String spaceDeleteConfirm(String space) {
    return 'Excluir o espaço $space? Os canais dele vão para o nível superior.';
  }

  @override
  String get workspaceMoveUp => 'Mover para cima';

  @override
  String get workspaceMoveDown => 'Mover para baixo';

  @override
  String get workspaceCannotReorder => 'Não foi possível reordenar.';

  @override
  String channelSettingsKbps(int kbps) {
    return '$kbps kbps';
  }

  @override
  String channelSettingsKbpsSpeech(int kbps) {
    return '$kbps kbps (voz)';
  }

  @override
  String channelSettingsKbpsMusic(int kbps) {
    return '$kbps kbps (música)';
  }

  @override
  String get createNewChannel => 'Novo canal';

  @override
  String get createNewSpace => 'Novo espaço';

  @override
  String get createSubmit => 'Criar';

  @override
  String get createChannel => 'Canal';

  @override
  String get createSpace => 'Espaço';

  @override
  String get createChannelHint =>
      'Uma sala de voz para as pessoas entrarem, com chat próprio.';

  @override
  String get createSpaceHint => 'Uma pasta que agrupa canais na barra lateral.';

  @override
  String get createChannelPlaceholder => 'Time Azul';

  @override
  String get channelSettingsTitle => 'Configurações do canal';

  @override
  String get channelSettingsOwnerHint =>
      'O dono gerencia este canal. Só administradores escolhem quem é o dono.';

  @override
  String channelSettingsDeleteConfirm(String name) {
    return 'Excluir $name? Todos que estiverem dentro serão desconectados.';
  }

  @override
  String get channelSettingsPeopleAndSound => 'Pessoas e som';

  @override
  String get channelSettingsMaxPeople => 'Máximo de pessoas';

  @override
  String get channelSettingsNoLimit => 'Sem limite';

  @override
  String get channelSettingsAudioQuality => 'Qualidade do áudio';

  @override
  String get channelSettingsStereo => 'Estéreo';

  @override
  String get channelSettingsDelete => 'Excluir canal…';

  @override
  String get manageSpace => 'Espaço';

  @override
  String get manageOwner => 'Dono';

  @override
  String get manageAccess => 'Acesso';

  @override
  String get spaceSettingsTitle => 'Configurações do espaço';

  @override
  String get spaceSettingsOwnerHint =>
      'O dono gerencia o espaço e todos os canais dele. Só administradores escolhem quem é o dono.';

  @override
  String get accessAccountsOnly => 'Somente contas';

  @override
  String get accessAccountsOnlyDetail => 'Sem convidados';

  @override
  String get accessWhitelistOnly => 'Somente lista de permissões';

  @override
  String get accessHidden => 'Oculto';

  @override
  String get accessHiddenDetail => 'Invisível para quem não pode entrar';

  @override
  String get accessFromSpace => 'Definido pelo espaço';

  @override
  String summonsTitle(String channel) {
    return 'Chamar para $channel';
  }

  @override
  String get summonsSummon => 'Chamar';

  @override
  String get summonsNickname => 'Apelido';

  @override
  String get summonsNoMatch => 'Ninguém correspondente pode entrar aqui.';

  @override
  String get summonsHint =>
      'A pessoa recebe uma notificação de que você está esperando. Uma vez a cada 5 minutos por pessoa.';

  @override
  String get summonsSearchFailed => 'Não foi possível pesquisar.';

  @override
  String get manageDeviceKey => 'Chave do dispositivo';

  @override
  String manageDeleteTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get manageDelete => 'Excluir';

  @override
  String get manageSave => 'Salvar';

  @override
  String get manageName => 'Nome';

  @override
  String get manageNone => 'Nenhum';

  @override
  String get manageNobody => 'Ninguém';

  @override
  String get manageSomeoneElse => 'Outra pessoa';

  @override
  String get manageWhitelistInWeb =>
      'Por enquanto, edite a lista de permissões no cliente web.';

  @override
  String get channelSettingsLimitHint =>
      'Quando o canal está cheio, só quem o gerencia ainda pode entrar. De 1 a 99 pessoas, ou sem limite.';

  @override
  String get spaceSettingsAccessHint =>
      'Estes limites valem para todos os canais do espaço; um canal só pode adicionar os seus. Por enquanto, edite a lista de permissões no cliente web.';

  @override
  String get accessWhitelistOnlyListDetail => 'Só as pessoas e cargos da lista';

  @override
  String get summonsWho => 'Quem?';

  @override
  String get settingsPictures => 'Imagens';

  @override
  String get profileAddPicture => 'Adicionar foto…';

  @override
  String get profileChangePicture => 'Alterar foto…';

  @override
  String get profileRemovePicture => 'Remover foto';

  @override
  String get profileUploadFailed => 'Não foi possível enviar a foto.';

  @override
  String get profileRemoveFailed => 'Não foi possível remover a foto.';

  @override
  String get saveFailed => 'Não foi possível salvar.';

  @override
  String get settingsAudioVideo => 'Áudio e vídeo';

  @override
  String get settingsMicrophone => 'Microfone';

  @override
  String get settingsCamera => 'Câmera';

  @override
  String get settingsOutput => 'Saída';

  @override
  String get settingsVoiceProcessing => 'Processamento de voz';

  @override
  String get settingsVoiceProcessingDetail =>
      'Supressão de ruído e cancelamento de eco';

  @override
  String get settingsVoiceProcessingHint =>
      'Desative para ter o melhor som, mas use fones de ouvido: sem cancelamento de eco, os outros ouvem a própria voz pelos seus alto-falantes.';

  @override
  String get settingsCues => 'Sons de entrada e saída';

  @override
  String get settingsCuesDetail =>
      'Uma coruja pia quando alguém entra ou sai, e os atalhos fazem um clique';

  @override
  String get settingsPingAndLoss => 'Mostrar ping e perda';

  @override
  String get settingsPingAndLossDetail =>
      'Ao lado do ícone de conexão em uma chamada';

  @override
  String get summonsHeader => 'Convocações';

  @override
  String get summonsAllow => 'Outros podem me chamar';

  @override
  String get settingsNotificationsHere => 'Notificações neste dispositivo';

  @override
  String get settingsNotificationsHint =>
      'Aparecem enquanto o Wisetalk está em segundo plano.';

  @override
  String get settingsNotifyMessages => 'Novas mensagens';

  @override
  String get settingsNotifyMessagesDetail =>
      'No chat da sua chamada e nos chats que você abriu';

  @override
  String get settingsNotifySummons => 'Convocações';

  @override
  String get settingsNotifySummonsDetail =>
      'Quando alguém chama você para um canal';

  @override
  String get settingsPushHeader => 'Com o Wisetalk fechado';

  @override
  String get settingsPushApp => 'App de notificações';

  @override
  String get settingsPushAppNone => 'Nenhum';

  @override
  String get settingsPushAppChoose => 'Escolher…';

  @override
  String get settingsGetNtfy => 'Baixar o ntfy';

  @override
  String settingsPushVia(String app) {
    return 'As convocações chegam a este celular pelo $app, mesmo com o Wisetalk fechado.';
  }

  @override
  String get settingsPushChooseHint =>
      'Escolha o app que recebe as convocações com o Wisetalk fechado.';

  @override
  String get settingsPushNoneHint =>
      'Sem um app de notificações, as convocações só aparecem com o Wisetalk aberto. Instale o ntfy e, nas configurações dele, defina o servidor ntfy da sua comunidade como padrão.';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get settingsCrashReports => 'Enviar relatórios de falhas';

  @override
  String get settingsCrashReportsHint =>
      'Quando algo no Wisetalk quebra, conta aos desenvolvedores o que quebrou e onde no código. Nunca suas mensagens, nomes, chaves ou servidores.';

  @override
  String get settingsShortcuts => 'Atalhos';

  @override
  String get settingsShortcutsRecording =>
      'Pressione as novas teclas. Backspace remove o atalho, Esc mantém o atual.';

  @override
  String get settingsShortcutsGlobal =>
      'Em uma chamada, funcionam com qualquer app em primeiro plano; fora dela, na janela do Wisetalk. Clique em um para alterar.';

  @override
  String get settingsShortcutsWayland =>
      'No Wayland, funcionam só enquanto a janela do Wisetalk está em primeiro plano. Clique em um para alterar.';

  @override
  String get settingsShortcutPressKeys => 'Pressione as teclas…';

  @override
  String get settingsShortcutNone => 'Nenhum';

  @override
  String settingsShortcutTaken(String keys, String action) {
    return '$keys já é “$action”.';
  }

  @override
  String get shortcutToggleMute => 'Ligar ou desligar microfone';

  @override
  String get shortcutToggleAway => 'Ausente ou de volta';

  @override
  String get shortcutMute => 'Desligar microfone';

  @override
  String get shortcutUnmute => 'Ligar microfone';

  @override
  String get shortcutUnusableKey =>
      'Essa tecla não pode ser usada em um atalho.';

  @override
  String shortcutTyping(String first, String second) {
    return 'Adicione $first ou $second, ou use F1 a F24.';
  }

  @override
  String shortcutReserved(String keys) {
    return '$keys pertence ao sistema ou a todos os apps.';
  }

  @override
  String get sheetDiscardTitle => 'Descartar alterações?';

  @override
  String get sheetDiscardMessage =>
      'O que você mudou aqui ainda não foi salvo.';

  @override
  String get sheetDiscard => 'Descartar';

  @override
  String get sheetKeepEditing => 'Continuar editando';

  @override
  String serversRemoveTitle(String server) {
    return 'Remover $server?';
  }

  @override
  String get serversRemoveMessage =>
      'Este dispositivo sai da conta nele e o esquece. Você pode adicioná-lo de novo pelo endereço.';

  @override
  String get serversRemove => 'Remover';

  @override
  String get serversAddressHelp =>
      'Peça o endereço a quem administra sua comunidade.';

  @override
  String get serversConnecting => 'Conectando…';

  @override
  String get serversConnect => 'Conectar';

  @override
  String get serversWhich => 'Em qual servidor está sua comunidade?';

  @override
  String get serversYours => 'Seus servidores';

  @override
  String get serversAddMenu => 'Adicionar servidor…';

  @override
  String get serversAddTitle => 'Adicionar servidor';

  @override
  String get serversBadAddress =>
      'Digite o endereço de um servidor, como talk.example.com.';

  @override
  String get serversTooNew =>
      'Este servidor é mais novo que este app. Atualize o Wisetalk para entrar.';

  @override
  String get serversTooOld =>
      'Este servidor roda um Wisetalk mais antigo. Peça aos administradores para atualizá-lo.';

  @override
  String serversTooOldVersion(String version) {
    return 'Este servidor roda um Wisetalk mais antigo ($version). Peça aos administradores para atualizá-lo.';
  }

  @override
  String get serversAddress => 'Endereço';

  @override
  String get serversMore => 'Mais';

  @override
  String get serversRemoveServer => 'Remover servidor';

  @override
  String get channelSomeChannel => 'um canal';

  @override
  String workspaceMessageTitle(String name, String channel) {
    return '$name em $channel';
  }

  @override
  String get workspaceMessageEncrypted =>
      'Escreveu uma mensagem criptografada.';

  @override
  String get workspaceMessagePicture => 'Enviou uma imagem.';

  @override
  String summonPushed(String name) {
    return '$name recebeu uma notificação.';
  }

  @override
  String get summonPushedSomeone => 'Notificação enviada.';

  @override
  String summonNotPushed(String name) {
    return 'Você chamou $name. As notificações estão desativadas, então só um Wisetalk aberto vai mostrar.';
  }

  @override
  String get summonNotPushedSomeone =>
      'Chamado enviado. As notificações estão desativadas, então só um Wisetalk aberto vai mostrar.';

  @override
  String summonReceived(String from, String channel) {
    return '$from está chamando você para $channel.';
  }

  @override
  String get workspaceSummoned => 'Alguém está chamando você';

  @override
  String get workspaceRoleChangedOwner => 'Seu papel no servidor agora é dono.';

  @override
  String get workspaceRoleChangedAdmin =>
      'Seu papel no servidor agora é administrador.';

  @override
  String get workspaceRoleChangedModerator =>
      'Seu papel no servidor agora é moderador.';

  @override
  String get workspaceRoleChangedMember =>
      'Seu papel no servidor agora é membro.';

  @override
  String get workspaceRoleChangedGuest =>
      'Seu papel no servidor agora é convidado.';

  @override
  String get takeOverTitle => 'Entrar por este dispositivo?';

  @override
  String takeOverSameChannel(String channel) {
    return 'Você já está em $channel em outro dispositivo ou aba. Entrar em $channel aqui tira você da chamada de lá.';
  }

  @override
  String takeOverOtherChannel(String there, String here) {
    return 'Você está em $there em outro dispositivo ou aba. Entrar em $here aqui tira você da chamada de lá.';
  }

  @override
  String get takeOverElsewhere =>
      'Você está em uma chamada em outro dispositivo ou aba. Entrar aqui tira você da chamada de lá.';

  @override
  String get takeOverJoinHere => 'Entrar aqui';

  @override
  String get workspaceShowChannels => 'Mostrar canais';

  @override
  String get workspaceHideChannels => 'Ocultar canais';

  @override
  String workspaceInVoice(int count) {
    return '$count na voz';
  }

  @override
  String get workspaceCreateTitle => 'Novo canal ou espaço';

  @override
  String get workspaceStatusConnecting => 'Conectando…';

  @override
  String get workspaceStatusOffline => 'Offline…';

  @override
  String get workspaceEmptyAdmin =>
      'Nenhum canal ainda. Crie um com o botão +.';

  @override
  String get workspaceEmpty =>
      'Nenhum canal ainda. Um administrador pode adicionar.';

  @override
  String get workspaceMore => 'Mais';

  @override
  String get workspaceCheckForUpdates => 'Verificar atualizações';

  @override
  String get workspaceChangeServer => 'Trocar de servidor';

  @override
  String get workspaceSignOut => 'Sair';

  @override
  String get personMutedForYou => 'Silenciado para você';

  @override
  String get awayTitle => 'Ausente';

  @override
  String get awayDescription => 'Ausente: microfone e som desligados';

  @override
  String get callMutedByModerator => 'Silenciado por um moderador';

  @override
  String workspaceDrag(String name) {
    return 'Arrastar $name';
  }

  @override
  String get workspaceDropEndHint =>
      'Solte aqui para mover para o fim da lista';

  @override
  String workspaceUpdateDownloaded(String version) {
    return 'O Wisetalk $version foi baixado';
  }

  @override
  String workspaceUpdateOut(String version) {
    return 'Saiu o Wisetalk $version';
  }

  @override
  String get workspaceRestartToUpdate => 'Reiniciar para atualizar';

  @override
  String workspaceUpdateTo(String version) {
    return 'Atualizar para $version';
  }

  @override
  String get workspaceWelcomeTitle => 'Escolha um canal de voz';

  @override
  String get workspaceWelcomeHint => 'Clique em um canal para entrar.';

  @override
  String get callJoining => 'Entrando…';

  @override
  String get callWaitingForKey => 'Aguardando a chave da chamada…';

  @override
  String get callEncrypted => 'Criptografia de ponta a ponta';

  @override
  String videoScreen(String name) {
    return '$name · tela';
  }

  @override
  String get connectionExcellent => 'excelente';

  @override
  String get connectionGood => 'boa';

  @override
  String get connectionPoor => 'fraca';

  @override
  String get connectionLost => 'perdida';

  @override
  String get connectionChecking => 'verificando';

  @override
  String connectionStatus(String quality) {
    return 'Conexão: $quality';
  }

  @override
  String get connectionLabel => 'Conexão';

  @override
  String connectionShort(String ping, String loss) {
    return '$ping · $loss de perda';
  }

  @override
  String connectionPingLoss(String ping, String loss) {
    return 'Ping $ping, perda $loss';
  }

  @override
  String get connectionPing => 'Ping';

  @override
  String get connectionOutgoingLoss => 'Perda de saída';

  @override
  String get connectionIncomingLoss => 'Perda de entrada';

  @override
  String get connectionJitter => 'Jitter';

  @override
  String get connectionMicrophone => 'Microfone';

  @override
  String get connectionNotSending => 'Sem envio';

  @override
  String connectionKilobits(int value) {
    return '$value kbps';
  }

  @override
  String get screenShareTitle => 'Compartilhar sua tela';

  @override
  String get screenShareAction => 'Compartilhar';

  @override
  String get screenShareBestFor => 'Ideal para';

  @override
  String get screenShareAndroidHint =>
      'Em seguida, o Android pergunta se você quer compartilhar a tela inteira ou um app.';

  @override
  String get screenShareWaylandHint =>
      'Na primeira vez, o sistema pergunta qual tela compartilhar. Depois, a mesma tela é usada até o Wisetalk reiniciar. Por enquanto, só telas inteiras e sem som.';

  @override
  String get screenShareText => 'Texto e slides';

  @override
  String get screenShareTextDetail =>
      'Nítido e leve: poucos quadros por segundo.';

  @override
  String get screenShareMotion => 'Vídeos e jogos';

  @override
  String get screenShareMotionDetail =>
      'Fluido: 30 quadros por segundo, mais pesado dos dois lados.';

  @override
  String get screenShareSource => 'Tela ou janela';

  @override
  String get screenShareSound => 'Compartilhar som';

  @override
  String get screenShareSoundWindow => 'Só o app desta janela.';

  @override
  String get screenShareSoundScreen => 'Tudo o que você ouve, sem a chamada.';

  @override
  String get screenShareSoundAny =>
      'O app de uma janela ou, para uma tela, tudo o que você ouve, sem a chamada.';

  @override
  String get screenShareSoundPhone =>
      'Tudo o que toca no celular, sem a chamada. Alguns apps não permitem.';

  @override
  String get screenShareListFailed =>
      'Não foi possível listar telas e janelas.';

  @override
  String get screenShareChooseTitle => 'Escolha uma tela';

  @override
  String get screenShareChooseHint =>
      'Escolha a tela para compartilhar na janela do sistema.';

  @override
  String get problemNotSignedIn => 'Você não fez login.';

  @override
  String get problemAccountRequired => 'Entre com uma conta primeiro.';

  @override
  String get problemAccountBanned => 'Esta conta está banida.';

  @override
  String get problemSignInCodeInvalid =>
      'Este código de login não é mais válido. Entre de novo.';

  @override
  String get problemBrowserCheckMissing =>
      'Falta a verificação do navegador. Recarregue e tente de novo.';

  @override
  String get problemBrowserCheckFailed =>
      'A verificação do navegador falhou. Recarregue e tente de novo.';

  @override
  String get problemBrowserCheckExpired =>
      'A verificação do navegador expirou. Tente de novo.';

  @override
  String get problemGuestSignInClosed =>
      'O login de convidados está fechado agora. Entre com uma conta.';

  @override
  String get problemGuestAddressBlocked =>
      'Convidados deste endereço estão bloqueados por um tempo.';

  @override
  String get problemTooManyGuests =>
      'Há convidados demais agora. Tente mais tarde ou entre com uma conta.';

  @override
  String get problemTooManyGuestSignIns =>
      'Logins de convidados demais deste endereço. Tente mais tarde.';

  @override
  String get problemNameBelongsToAccount => 'Este nome pertence a uma conta.';

  @override
  String get problemAccountsCantBeGuests => 'Contas não podem ser convidados.';

  @override
  String get problemNoSuchAccount => 'Esta conta não existe.';

  @override
  String get problemNoSuchChannel => 'Este canal não existe mais.';

  @override
  String get problemNoSuchSpace => 'Este espaço não existe mais.';

  @override
  String get problemNoSuchEmoji => 'Este emoji não existe.';

  @override
  String get problemNoSuchGuest => 'Este convidado não está mais on-line.';

  @override
  String get problemNoSuchPicture => 'Esta imagem não existe mais.';

  @override
  String get problemNoSuchMessage => 'Esta mensagem não existe mais.';

  @override
  String get problemNoAvatar => 'Não há foto.';

  @override
  String get problemNotBanned => 'Esta conta não está banida.';

  @override
  String get problemDisplayNameLength => 'Um nome tem de 1 a 32 caracteres.';

  @override
  String get problemChannelNameLength =>
      'Um nome de canal tem de 1 a 64 caracteres.';

  @override
  String get problemSpaceNameLength =>
      'Um nome de espaço tem de 1 a 64 caracteres.';

  @override
  String get problemEmojiNameInvalid =>
      'Um nome de emoji tem de 2 a 32 caracteres entre a–z, 0–9 e _.';

  @override
  String get problemIconInvalid => 'Um ícone é um emoji ou um :custom_emoji:.';

  @override
  String get problemBrandingInvalid =>
      'Os nomes têm até 40 caracteres e o slogan até 120, sem caracteres de controle.';

  @override
  String get problemChannelLimitInvalid =>
      'Um canal comporta de 1 a 99 pessoas ou não tem limite.';

  @override
  String get problemBitrateInvalid =>
      'A taxa de bits do áudio deve ser de 6 a 510 kbit/s.';

  @override
  String get problemPictureType => 'A imagem deve ser PNG, JPEG ou WebP.';

  @override
  String get problemAvatarTooLarge => 'A imagem tem mais de 256 KB.';

  @override
  String get problemEmojiTooLarge => 'A imagem tem mais de 128 KB.';

  @override
  String get problemChatPictureTooLarge => 'Uma imagem pode ter até 20 MB.';

  @override
  String get problemPictureIdTaken => 'Esta imagem já está aqui.';

  @override
  String get problemChatFullOfPictures =>
      'Este chat já tem imagens demais. Espere até ele ser limpo.';

  @override
  String get problemTooManyPictures => 'São imagens demais. Espere um pouco.';

  @override
  String get problemManageNotPerRole =>
      'A permissão de gerenciar não pode ser dada por cargo.';

  @override
  String get problemOwnersHaveEveryPermission =>
      'Donos e administradores sempre têm todas as permissões.';

  @override
  String get problemOneOverridePerRole => 'Só uma regra por cargo.';

  @override
  String get problemWhitelistUnknownAccount =>
      'A lista de permissões cita uma conta que não existe.';

  @override
  String get problemGuestsNeverWhitelisted =>
      'Convidados nunca passam por uma lista de permissões.';

  @override
  String get problemPushSubscriptionInvalid =>
      'O navegador enviou uma inscrição de notificações inválida.';

  @override
  String get problemPushEndpointNotPublic =>
      'O endereço de notificações deve ser um endereço HTTPS público.';

  @override
  String get problemNotAllowedInChannel =>
      'Você não pode fazer isso neste canal.';

  @override
  String get problemMayNotEnter => 'Você não pode entrar neste canal.';

  @override
  String get problemTheyMayNotEnter =>
      'Essa pessoa não pode entrar neste canal.';

  @override
  String get problemMayNotModerate => 'Você não pode moderar este canal.';

  @override
  String get problemCantModerateYourself => 'Você não pode moderar a si mesmo.';

  @override
  String get problemModerateRank =>
      'Você não pode moderar alguém do seu nível ou acima.';

  @override
  String get problemBanRank =>
      'Você não pode banir alguém do seu nível ou acima.';

  @override
  String get problemRoleRank =>
      'Você só pode dar cargos abaixo do seu a pessoas abaixo de você.';

  @override
  String get problemOnlyAdminsManageServer =>
      'Só donos e administradores do servidor gerenciam o servidor.';

  @override
  String get problemOnlyAdminsManageBans =>
      'Só donos e administradores do servidor gerenciam os banimentos.';

  @override
  String get problemOnlyAdminsManageEmoji =>
      'Só donos e administradores do servidor gerenciam emojis personalizados.';

  @override
  String get problemOnlyAdminsManageSpaces =>
      'Só donos e administradores do servidor gerenciam espaços.';

  @override
  String get problemOnlyAdminsChooseChannelOwners =>
      'Só donos e administradores do servidor escolhem os donos dos canais.';

  @override
  String get problemOnlyAdminsChooseSpaceOwners =>
      'Só donos e administradores do servidor escolhem os donos dos espaços.';

  @override
  String get problemOnlySpaceManagersManageSpace =>
      'Só administradores e o dono do espaço podem gerenciá-lo.';

  @override
  String get problemOnlySpaceManagersCreateChannels =>
      'Só administradores, e donos de espaço no próprio espaço, podem criar canais.';

  @override
  String get problemMoveIntoOwnSpace =>
      'Você só pode mover canais para um espaço que você gerencia.';

  @override
  String get problemOnlyModeratorsInvite =>
      'Só quem pode moderar o canal pode criar convites.';

  @override
  String get problemGuestsCantCreateChannels =>
      'Convidados não podem criar canais.';

  @override
  String get problemGuestsCantInvite => 'Convidados não podem convidar.';

  @override
  String get problemGuestsCantBan => 'Convidados não podem banir.';

  @override
  String get problemGuestsCantGetNotifications =>
      'Convidados não podem receber notificações.';

  @override
  String get problemGuestsHaveNoAvatar => 'Convidados não têm foto.';

  @override
  String get problemNotYourDevice => 'Esse dispositivo não é seu.';

  @override
  String get problemDeviceOfAnotherAccount =>
      'Este dispositivo pertence a outra conta.';

  @override
  String get problemOwnMessagesOnly =>
      'Você só pode apagar suas próprias mensagens.';

  @override
  String get problemChannelFull => 'Este canal está lotado.';

  @override
  String get problemInviteUsed => 'Este convite já foi usado ou expirou.';

  @override
  String get problemTooManyInvites =>
      'Há convites não usados demais. Espere alguns expirarem.';

  @override
  String get problemJoinChannelFirst => 'Entre no canal primeiro.';

  @override
  String get problemNotInVoice => 'Você não está em um canal de voz.';

  @override
  String get problemNotInThatChannel => 'Você não está nesse canal.';

  @override
  String get problemPersonNotInYourChannel =>
      'Essa pessoa não está no seu canal.';

  @override
  String get problemDeviceNotInChannel => 'Esse dispositivo não está no canal.';

  @override
  String get problemDeviceNotOnline =>
      'Esse dispositivo não está on-line ou não pode entrar.';

  @override
  String get problemVoiceNotConfigured =>
      'A voz não está configurada neste servidor.';

  @override
  String get problemSummonNeedsAccount =>
      'Entre com uma conta para chamar alguém.';

  @override
  String get problemCantSummonYourself => 'Você não pode chamar a si mesmo.';

  @override
  String get problemAlreadyHere => 'Essa pessoa já está aqui.';

  @override
  String get problemSummonsOff => 'Essa pessoa desativou as convocações.';

  @override
  String get problemSummonedRecently =>
      'Você chamou essa pessoa há menos de 5 minutos.';

  @override
  String get problemMessageLength => 'Uma mensagem tem de 1 a 2000 caracteres.';

  @override
  String get problemUploadPictureFirst => 'A imagem não foi enviada.';

  @override
  String get problemPictureNotAccepted => 'Este chat não aceita esta imagem.';

  @override
  String get problemChatHasNoKey => 'Este chat ainda não tem chave.';

  @override
  String get problemNobodyHasChatKey =>
      'Ninguém on-line tem a chave deste chat.';

  @override
  String get problemNotCurrentChatKey => 'Essa não é a chave atual do chat.';

  @override
  String get problemChatKeyChanged => 'A chave do chat mudou. Tente de novo.';

  @override
  String get problemEnvelopesForAnotherKey =>
      'As chaves foram seladas para outra chave do chat.';

  @override
  String get problemSealForYourself => 'Sele a chave para você também.';

  @override
  String get problemSealDeviceCount =>
      'Uma chave é selada para 1 a 1000 dispositivos.';

  @override
  String get problemNoLongerAllowed => 'Você não tem mais acesso a este canal.';

  @override
  String get problemJoinedElsewhere => 'Você entrou por outro dispositivo.';

  @override
  String problemKickedBy(String by) {
    return '$by removeu você do canal.';
  }

  @override
  String problemGuestRemovedBy(String by) {
    return '$by removeu você. Convidados do seu endereço ficam bloqueados por um dia.';
  }

  @override
  String get problemBannedFromServer => 'Você foi banido deste servidor.';

  @override
  String get problemGuestSignInClosedByAdmin =>
      'Um administrador fechou o login de convidados.';

  @override
  String get problemHelloFirst =>
      'A conexão não estava pronta. Recarregue a página.';

  @override
  String get problemUnreadableCommand =>
      'O servidor não entendeu isso. Recarregue a página.';

  @override
  String get problemUnsupportedProtocol =>
      'Esta versão do Wisetalk é antiga demais para o servidor. Recarregue a página.';

  @override
  String get problemSlowDown => 'Mais devagar, por favor.';

  @override
  String get problemTooManyCommands =>
      'Ações demais de uma vez. Vá mais devagar.';

  @override
  String get problemGone => 'Isso não existe mais.';

  @override
  String get problemInternal => 'Algo deu errado no servidor.';

  @override
  String get problemTooLarge => 'Isso é grande demais para enviar.';

  @override
  String get problemUnavailable =>
      'O servidor não está respondendo. Tente de novo em um minuto.';
}
