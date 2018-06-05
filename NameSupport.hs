module Foundation.NameSupport (tableNameToModelName, columnNameToFieldName, pluralToSingular, humanize, ucfirst, lcfirst, fieldNameToColumnName) where

import           ClassyPrelude
import           Data.String.Conversions (cs)
import qualified Text.Inflections        as Inflector
import qualified Data.Text

-- `users` => `User`
-- `projects` => `Project`
tableNameToModelName :: Text -> Text
tableNameToModelName tableName = unwrapEither tableName $ Inflector.toCamelCased True $ cs (pluralToSingular tableName)

-- `email` => `email`
-- `project_id` => `projectId`
columnNameToFieldName :: Text -> Text
columnNameToFieldName columnName = unwrapEither columnName $ Inflector.toCamelCased False columnName

unwrapEither _ (Right value) = value
unwrapEither input (Left value) = error "Foundation.NameSupport: " <> tshow value <> " (value to be transformed: " <>  tshow input <> ")"

-- `email` => `email`
-- `projectId` => `project_id`
fieldNameToColumnName :: Text -> Text
fieldNameToColumnName columnName = unwrapEither columnName $ Inflector.toUnderscore columnName


pluralToSingular :: Text -> Text
pluralToSingular w    | toLower w == "status"
                      || toLower w == "inprogress"
                      || toLower w == "in_progress"
                      = w
pluralToSingular word = fromMaybe word (stripSuffix "s" word)

humanize text = unwrapEither text $ Inflector.toHumanized True text

applyFirst :: (Text -> Text) -> Text -> Text
applyFirst f text =
    let (first, rest) = Data.Text.splitAt 1 text
    in (f first) <> rest

lcfirst :: Text -> Text
lcfirst = applyFirst Data.Text.toLower

ucfirst :: Text -> Text
ucfirst = applyFirst Data.Text.toUpper
