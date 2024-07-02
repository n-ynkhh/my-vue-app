const MyComponent = ({ columns, data }) => {
  const [searchText, setSearchText] = useState('');
  const [highlightIndex, setHighlightIndex] = useState(-1);

  const handleSearchChange = (event) => {
    setSearchText(event.target.value);
    setHighlightIndex(-1);
  };

  const filteredData = useMemo(() => {
    if (!searchText) return data;
    return data.filter(row => 
      row.some(cell => String(cell).toLowerCase().includes(searchText.toLowerCase()))
    );
  }, [data, searchText]);

  return (
    <div>
      <input
        type="text"
        value={searchText}
        onChange={handleSearchChange}
        placeholder="検索..."
      />
      <MyTable columns={columns} data={filteredData} />
    </div>
  );
};




const MyComponent = ({ columns, data }) => {
  const [searchText, setSearchText] = useState('');
  const [highlightIndex, setHighlightIndex] = useState(-1);

  const handleSearchChange = (event) => {
    setSearchText(event.target.value);
    setHighlightIndex(-1);
  };

  const filteredData = useMemo(() => {
    if (!searchText) return data;
    return data.filter(row => 
      row.some(cell => String(cell).toLowerCase().includes(searchText.toLowerCase()))
    );
  }, [data, searchText]);

  const matchCount = filteredData.length;

  return (
    <div>
      <input
        type="text"
        value={searchText}
        onChange={handleSearchChange}
        placeholder="検索..."
      />
      <span>{matchCount}件の該当結果</span>
      <MyTable columns={columns} data={filteredData} />
    </div>
  );
};





const MyComponent = ({ columns, data }) => {
  const [searchText, setSearchText] = useState('');
  const [highlightIndex, setHighlightIndex] = useState(-1);

  const handleSearchChange = (event) => {
    setSearchText(event.target.value);
    setHighlightIndex(-1);
  };

  const filteredData = useMemo(() => {
    if (!searchText) return data;
    return data.filter(row => 
      row.some(cell => String(cell).toLowerCase().includes(searchText.toLowerCase()))
    );
  }, [data, searchText]);

  const matchCount = filteredData.length;

  const handleNextHighlight = () => {
    setHighlightIndex(prevIndex => {
      const nextIndex = (prevIndex + 1) % matchCount;
      return nextIndex;
    });
  };

  const handlePreviousHighlight = () => {
    setHighlightIndex(prevIndex => {
      const prevIndex = (prevIndex - 1 + matchCount) % matchCount;
      return prevIndex;
    });
  };

  return (
    <div>
      <input
        type="text"
        value={searchText}
        onChange={handleSearchChange}
        placeholder="検索..."
      />
      <span>{matchCount}件の該当結果</span>
      <button onClick={handlePreviousHighlight}>←</button>
      <button onClick={handleNextHighlight}>→</button>
      <MyTable columns={columns} data={filteredData} />
    </div>
  );
};
