export const convertToMatrix = (
  arr: number[],
  rows: number,
  cols: number
): number[][] => {
  const matrix: number[][] = [];

  for (let i = 0; i < rows; i++) {
    const row: number[] = arr.slice(i * cols, (i + 1) * cols);
    matrix.push(row);
  }

  return matrix;
};
