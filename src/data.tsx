export interface DataItem {
    name: string;
    industry: string;
    prefactures: string;
    employee: number | null;
    mane: number | null;
    sala: number | null;
    sales: number | null;
  }
  
  const data: DataItem[] = [
    {
        "name": "aaa1",
        "industry": "bbb1",
        "prefactures": "ccc1",
        "employee": 500,
        "mane": 53,
        "sala": 300,
        "sales": 8
      },
      {
        "name": "aaa2",
        "industry": "bbb2",
        "prefactures": "ccc1",
        "employee": 210,
        "mane": 95,
        "sala": 450,
        "sales": 67
      },
      {
        "name": "aaa3",
        "industry": "bbb2",
        "prefactures": "ccc3",
        "employee": 5500,
        "mane": 33,
        "sala": 600,
        "sales": 28
      },
      {
        "name": "aaa4",
        "industry": "bbb4",
        "prefactures": "ccc2",
        "employee": 3000,
        "mane": 2,
        "sala": 1200,
        "sales": 88
      },
      {
        "name": "aaa5",
        "industry": "bbb1",
        "prefactures": "ccc4",
        "employee": 1500,
        "mane": null,
        "sala": 800,
        "sales": 218
      },
      {
        "name": "aaa6",
        "industry": "bbb5",
        "prefactures": "ccc5",
        "employee": 20,
        "mane": 313,
        "sala": 1500,
        "sales": null
      },
      {
        "name": "aaa7",
        "industry": "bbb7",
        "prefactures": "ccc8",
        "employee": 800,
        "mane": 62,
        "sala": 450,
        "sales": 100
      }
  ];
  
  export default data;
  