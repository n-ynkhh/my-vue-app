// pageConfigs.ts

interface PageConfig {
  chart: boolean;
  table: boolean;
  conditions: {
    [key: string]: boolean;
  };
}

const pageConfigs: { [key: string]: PageConfig } = {
  mane: {
    chart: true,
    table: true,
    conditions: {
      industry: true,
      prefactures: true,
      employee: false,
    },
  },
  sala: {
    chart: true,
    table: true,
    conditions: {
      industry: true,
      prefactures: true,
      employee: false,
    },
  },
  sales: {
    chart: false,
    table: true,
    conditions: {
      industry: true,
      prefactures: true,
      employee: true,
    },
  },
};

export default pageConfigs;
