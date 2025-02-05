List<String> getChainEvents(String namespace) {
  switch (namespace) {
    case 'eip155':
      return ['accountsChanged', 'chainChanged'];
    case 'polkadot':

      return ['balanceChanged', 'blockFinalized'];
    default:

      return [];
  }
}