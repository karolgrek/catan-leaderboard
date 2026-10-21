class AppStrings {
  AppStrings._();

  // -- GENERAL --
  static const String appTitle = 'Catan Leaderboard';
  static const String appTagline = 'Track your settlements & victory points';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String remove = 'Remove';
  static const String saving = 'Saving...';
  static const String unknownSettler = 'Unknown Settler';

  // -- AUTHENTICATION & PASSWORD RESET --
  static const String loginTitle = 'Login';
  static const String registerTitle = 'Register';
  static const String nameLabel = 'Name';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String createAccountToggle = 'Create an account';
  static const String alreadyHaveAccountToggle = 'I already have an account';
  static const String authFailedError =
      'Authentication failed. Please check your credentials.';
  static const String notAuthenticated = 'Not authenticated.';

  static const String forgotPasswordButton = 'Forgot password?';
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordDescription =
      'Enter your email address and we will send you a link to set a new password.';
  static const String sendResetLinkButton = 'Send Reset Link';
  static const String emptyEmailError = 'Please enter your email address.';
  static const String resetEmailSentSuccess =
      'Password reset link has been sent to your email.';
  static const String userNotFoundError =
      'No user found with this email address.';
  static const String invalidEmailError = 'Invalid email address format.';
  static const String tooManyRequestsError =
      'Too many requests. Please try again later.';
  static const String resetPasswordGenericError =
      'Failed to send password reset email.';

  // -- GROUPS --
  static const String selectGroupSubtitle = 'Select a group to view rankings';
  static const String errorLoadingGroups = 'Error loading groups.';
  static const String noGroupsMessage =
      'You are not in any groups yet.\nCreate or Join one below!';
  static const String joinButton = 'Join';
  static const String createButton = 'Create';
  static const String copyGroupIdTooltip = 'Copy Group ID';
  static const String groupIdCopiedMessage = 'Group ID copied to clipboard!';

  static const String joinGroupTitle = 'Join Group';
  static const String groupIdLabel = 'Group ID';
  static const String groupIdHint = 'Enter 20-character Group ID';
  static const String emptyGroupIdError = 'Please enter a Group ID.';
  static const String joinedGroupSuccess =
      'Joined group! Select it from the list.';
  static const String joinGroupFailedError = 'Failed to join group.';

  static const String createGroupTitle = 'Create New Group';
  static const String groupNameLabel = 'Group Name';
  static const String groupNameHint = 'e.g. Weekend Boardgamers';
  static const String emptyGroupNameError = 'Please enter a group name.';
  static const String createdGroupSuccess = 'Group created successfully!';
  static const String createGroupFailedError = 'Failed to create group.';

  // -- LEADERBOARD & SESSIONS --
  static const String leaderboardTitle = 'Leaderboard';
  static const String noMembersFound = 'No members found.';
  static const String winrateLabel = 'Winrate';
  static const String sessionsTitle = 'Sessions';
  static const String noSessionsRecorded = 'No sessions recorded yet.';
  static const String showMoreButton = 'Show more';
  static const String newSessionButton = 'New Session';

  static String membersCount(int count) => '$count members';
  static String gamesCount(int count) => 'Games: $count';
  static String winsCount(int count) => 'Wins: $count';
  static String roundsRecordedCount(int count) => '$count rounds recorded';

  // -- SESSION EDITOR & DETAIL --
  static const String editSessionTitle = 'Edit Session';
  static const String newSessionTitle = 'New Session';
  static const String sessionDateLabel = 'Session Date';
  static const String notesOptionalLabel = 'Notes (Optional)';
  static const String selectPlayersTitle = 'Select Players';
  static const String noPlayersInGroup = 'No players in this group.';
  static const String selectAtLeastOnePlayerError =
      'Please select at least one player.';
  static const String saveSessionFailedError = 'Failed to save session.';

  static const String editSessionDataTooltip = 'Edit Session Data';
  static const String finishActiveRoundFirstError =
      'Finish the active round first!';
  static const String sessionFinishedSuccess = 'Session finished!';
  static const String finishSessionButton = 'Finish Session';
  static const String startNewRoundButton = 'Start New Round';
  static const String roundHistoryTitle = 'Round History';
  static const String noRoundsFinishedYet = 'No rounds finished yet.';

  static String sessionTitleWithDate(String readableDate) =>
      'Session: $readableDate';

  // -- ROUNDS & PHOTOS --
  static const String activeRoundTitle = 'Active Round';
  static const String activeRoundPrompt =
      'Who collected 10 victory points first?';
  static const String newRoundDialogTitle = 'New Round';
  static const String startRoundButton = 'Start Round';
  static const String finishRoundTitle = 'Finish Round';
  static const String editRoundTitle = 'Edit Round';
  static const String saveChangesButton = 'Save Changes';

  static const String playersLabel = 'Players';
  static const String selectWinnerLabel = 'Select Winner';
  static const String expansionsLabel = 'Expansions';
  static const String roundNotesHint = 'Round notes...';
  static const String photosOptionalLabel = 'Photos (Optional)';
  static const String photosSubtitle =
      'Add memories and photos from this round!';

  static const String winnerPhotoLabel = 'Winner Photo';
  static const String boardPhotoLabel = 'Board Photo';
  static const String groupPhotoLabel = 'Group Photo';
  static const String winnerThumbLabel = 'Winner';
  static const String boardThumbLabel = 'Board';
  static const String partyThumbLabel = 'Party';

  static const String takePhotoOption = 'Take a photo';
  static const String chooseFromGalleryOption = 'Choose from gallery';
  static const String tapToAddPhoto = 'Tap to add photo';
  static const String viewFullPhotoTooltip = 'View full photo';
  static const String changePhotoTooltip = 'Change photo';
  static const String failedToLoadImage = 'Failed to load image';

  static const String selectWinnerError = 'Please select a winner';
  static const String roundFinishedSuccess = 'Round finished successfully!';
  static const String roundUpdatedSuccess = 'Round updated!';
  static const String saveRoundFailedError = 'Failed to save round.';

  static String saveUploadError(Object error) =>
      'Error saving/uploading: $error';
  static String winnerPrefix(String name) => 'Winner: $name';
  static String playersPrefix(String names) => 'Players: $names';
  static String expansionsPrefix(String list) => 'Expansions: $list';
  static String notesPrefix(String notes) => 'Notes: $notes';

  // -- CATAN EXPANSIONS --
  static const String fiveSixPlayerExtension = '5-6 Player Extension';
  static const String frenemiesExpansion = 'Frenemies of Catan';
  static const String easterSantaExpansion = 'Easter Bunny & Santa Claus';

  static const List<String> catanExpansions = [
    fiveSixPlayerExtension,
    frenemiesExpansion,
    easterSantaExpansion,
  ];

  // -- NOTIFICATIONS UI --
  static const String notificationsTooltip = 'Notifications';
  static const String notificationsDialogTitle = 'Catan Notifications';
  static const String noNotificationsYet =
      'No notifications yet.\nStart a session or finish a round!';
  static const String phoneNotificationBarActive =
      'Phone notification bar is active';
  static const String testNotificationButton = 'Test';
  static const String notificationsBlockedMessage =
      'Notifications are blocked in browser settings. Allow notifications for this site to see them in your phone notification bar.';
  static const String enableNotificationsPrompt =
      'Enable notifications to receive Catan alerts directly in your phone notification bar!';
  static const String enablePhoneNotificationsButton =
      'Enable Phone Notifications';
  static const String notificationsEnabledSuccess = 'Notifications enabled!';
  static const String testNotificationBody =
      'Your scouts report that notifications are working! Prepare your settlements.';

  // -- FUNNY NOTIFICATION TEMPLATES (NO EMOJIS) --

  // 1. Left Behind / FOMO
  static String leftBehindTitle(String groupName) =>
      'Left Behind in $groupName';

  static List<String> leftBehindMessages(String groupName) => [
        'Betrayal! Your Catan hood in $groupName just started the fight without you!',
        'No sheep for you tonight! $groupName started a session and left you in the desert.',
        'The Robber just stole your seat at the table! $groupName is playing without you.',
        'They are trading wood for sheep behind your back! A new game in $groupName started without you.',
      ];

  // 3. Round Winner
  static String roundWinnerTitle(int roundNumber) =>
      'Round #$roundNumber Winner';

  static List<String> roundWinnerMessages(
    String winnerName,
    int roundNumber,
    String groupName,
  ) =>
      [
        'The winner of Round #$roundNumber is: $winnerName! Bow down to your new landlord.',
        'All hail $winnerName! They just conquered Round #$roundNumber in $groupName!',
        'Built on wheat, ore, and broken friendships: $winnerName takes the win in Round #$roundNumber!',
        'The winner of the round is: $winnerName! 10 Victory Points and zero mercy.',
      ];

  // 4. Dethroned / Kingslayer
  static String dethronedTitle(String groupName) => 'New #1 in $groupName';

  static List<String> dethronedMessages(
    String oldLeaderName,
    String newLeaderName,
    String groupName,
  ) =>
      [
        'KINGSLAYER! $oldLeaderName was just dethroned by $newLeaderName at the top of the leaderboard!',
        'Someone check on $oldLeaderName... $newLeaderName just stole the #1 crown in $groupName!',
        'A new ruler sits on the Catan throne! $oldLeaderName was dethroned by $newLeaderName!',
      ];

  // 5. Win Streak
  static const String winStreakTitle = 'Win Streak Alert';

  static List<String> twoWinStreakMessages(String winnerName) => [
        'STOP TRADING WITH THEM! $winnerName just won 2 games in a row!',
        'Warning: $winnerName is on a 2-win streak! Refuse all their sheep offers immediately.',
      ];

  static List<String> multiWinStreakMessages(
    String winnerName,
    int streakCount,
  ) =>
      [
        'EMBARGO ALERT: $winnerName is on a $streakCount-win streak! Whoever gives them brick is a traitor.',
        'Total domination! $winnerName just won $streakCount games in a row. Send the Robber after them!',
      ];

  // 6. Underdog / First Win
  static String miracleTitle(String groupName) => 'Miracle in $groupName';

  static List<String> firstWinEverMessages(
    String winnerName,
    String groupName,
  ) =>
      [
        'Hell just froze over! $winnerName finally won a game of Catan in $groupName!',
        'From humble settlements to a mighty empire: $winnerName just scored their FIRST win!',
      ];

  static List<String> brokenLosingStreakMessages(
    String winnerName,
    int losingStreak,
  ) =>
      [
        'The curse is broken! After $losingStreak losses in a row, $winnerName finally won a game of Catan!',
        'Hell just froze over! $winnerName ended a $losingStreak-game losing streak and took the win!',
      ];

  // 7. Crime Scene Photos
  static const String crimeScenePhotosTitle = 'Crime Scene Photos';

  static List<String> photosUploadedMessages(
    int roundNumber,
    String groupName,
  ) =>
      [
        'Pics or it didn\'t happen! New crime scene photos from Round #$roundNumber were just uploaded.',
        'Go look at the faces of defeat! New photos added to Round #$roundNumber in $groupName.',
        'Evidence has been secured! Check out the new photos from the latest round in $groupName.',
      ];

  // 8. Session Summary
  static String sessionFinishedTitle(String groupName) =>
      'Session Finished in $groupName';

  static List<String> sessionSummaryMessages(
    String sessionWinnerName,
    String groupName,
  ) =>
      [
        'The dust has settled! The winner of the session is: $sessionWinnerName!',
        'Session over! Friendships ruined: many. The winner of the session is: $sessionWinnerName!',
        'Tonight\'s ultimate Catan champion in $groupName is: $sessionWinnerName!',
      ];
}
