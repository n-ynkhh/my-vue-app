export interface DataItem {
    name: string;
    industry: string;
    prefactures: string;
    num1: number;
    num2: number;
    num3: number;
  }
  
  const data: DataItem[] = [
    {
        "name": "aaa1",
        "industry": "bbb1",
        "prefactures": "ccc1",
        "num1": 53,
        "num2": 89,
        "num3": 8
      },
      {
        "name": "aaa2",
        "industry": "bbb2",
        "prefactures": "ccc1",
        "num1": 95,
        "num2": 34,
        "num3": 67
      },
      {
        "name": "aaa3",
        "industry": "bbb2",
        "prefactures": "ccc3",
        "num1": 33,
        "num2": 9,
        "num3": 28
      }
  ];
  
  export default data;
  