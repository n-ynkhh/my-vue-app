// src/state/filterState.ts
import { atom } from 'recoil';

export const filterState = atom({
  key: 'filterState',
  default: {
    industry: [],
    prefactures: []
  },
});
