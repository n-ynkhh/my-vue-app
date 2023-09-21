import { atom } from 'recoil';

export const loginState = atom({
  key: 'loginState',
  default: { isLoggedIn: false, userId: null as string | null },
});