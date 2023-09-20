import { atom } from 'recoil';

export interface CheckboxStateType {
  industry: string[];
  prefactures: string[];
}

export const checkboxState = atom<CheckboxStateType>({
  key: 'checkboxState',
  default: {
    industry: [],
    prefactures: []
  }
});
