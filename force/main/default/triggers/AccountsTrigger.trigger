trigger AccountsTrigger on Account (after insert, after update) {
	Accounts.newInstance().handleTrigger();
}
