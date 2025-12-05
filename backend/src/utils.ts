export const parseNumber = (value: any): number | undefined => {
  if (value === undefined || value === null || value === '') return undefined
  const n = Number(value)
  return Number.isNaN(n) ? undefined : n
}
