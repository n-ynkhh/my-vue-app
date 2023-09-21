// checkboxState.ts
import { atom } from 'recoil';

export interface CheckboxItems {
  [key: string]: boolean;
}

export const checkboxState = atom<CheckboxItems>({
  key: 'checkboxState',
  default: {}
});
